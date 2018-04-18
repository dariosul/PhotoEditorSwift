/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The CanvasImageView is a basic NSView subclass. It demonstrates manually drawing an image inside of a normal draw() method, along with event tracking. The event tracking moves the clip view that contains the image, or allows drawing on top of it.
*/


import Cocoa
import OpenGL.GL3
import OpenGL.GL


class CanvasImageView: NSOpenGLView {

    var _contextOptions: NSMutableDictionary? = nil
    var _ciImage: CIImage? = nil
    var _context: CIContext? = nil
    var cglContext: CGLContextObj? = nil
    var pf: NSOpenGLPixelFormat? = nil
    
    override class func defaultPixelFormat() -> NSOpenGLPixelFormat {

        let attrs: [NSOpenGLPixelFormatAttribute] = [
            UInt32(NSOpenGLPFAAccelerated),
            UInt32(NSOpenGLPFANoRecovery),
            UInt32(NSOpenGLPFAColorSize), UInt32(32),
            UInt32(NSOpenGLPFAAllowOfflineRenderers),
            UInt32(0)
        ]
        return NSOpenGLPixelFormat(attributes: attrs)!
    }
    
    override func prepareOpenGL() {
        var parm: GLint = 1

        /* Enable beam-synced updates. */
        self.openGLContext?.setValues(&parm, for: NSOpenGLCPSwapInterval)

        /* Make sure that everything we don't need is disabled. Some of these
         * are enabled by default and can slow down rendering. */

        glDisable(GLenum(GL_ALPHA_TEST))
        glDisable(GLenum(GL_DEPTH_TEST))
        glDisable(GLenum(GL_SCISSOR_TEST))
        glDisable(GLenum(GL_BLEND))
        glDisable(GLenum(GL_DITHER))
        glDisable(GLenum(GL_CULL_FACE))
        glColorMask(GLboolean(GL_TRUE), GLboolean(GL_TRUE), GLboolean(GL_TRUE), GLboolean(GL_TRUE))
        glDepthMask(GLboolean(GL_FALSE))
        glStencilMask(0)
        glClearColor(0.0, 0.0, 0.0, 0.0)
        glHint(GLenum(GL_TRANSFORM_HINT_APPLE), GLenum(GL_FASTEST))
    }
    
    //////
    
    var image: NSImage? {
        didSet(oldImage) {
            if (oldImage != image) {
                _ciImage = nil
                self.clearView()
                
                needsDisplay = true
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    func viewBoundsDidChange(_ bounds: NSRect) -> Void {
        /* For subclasses. */
    }
    
    func clearView() -> Void {
         /* For subclasses. */
    }

    
    func getCIImage() -> CIImage? {
        if _ciImage == nil && image != nil {
            
            /* Convert NSImage to CIImage */
            let imageData = image?.tiffRepresentation
            let sourceData = CGImageSourceCreateWithData(imageData! as CFData, nil)
            let cgImage: CGImage? = CGImageSourceCreateImageAtIndex(sourceData!, 0, nil)
            _ciImage = CIImage(cgImage: cgImage!)
        }
        
        return _ciImage
    }
    
    func setCIImage(_ image: CIImage) -> Void {
        self.setCIImage(image, dirtyRect: CGRect.infinite)
    }
    
    func setCIImage(_ image: CIImage, dirtyRect rect: CGRect) -> Void {
   
        if image != self._ciImage {
            
            self._ciImage = image
            if rect.isInfinite {
                self.needsDisplay = true
            } else {
                self.setNeedsDisplay(rect)
            }
        }
    }
    
    var _lastBounds: NSRect? = nil
    func updateMatrices() -> Void {
        let r = self.bounds
        if _lastBounds == nil || (_lastBounds != nil && !NSEqualRects(r, _lastBounds!)) {
            self.openGLContext?.update()
            
            /* Install an orthographic projection matrix (no perspective)
             * with the origin in the bottom left and one unit equal to one
             * device pixel. */
            
            glViewport(0, 0, GLsizei(r.size.width), GLsizei(r.size.height));
            
            glMatrixMode(UInt32(GL_PROJECTION));
            glLoadIdentity();
            glOrtho(0, GLdouble(r.size.width), 0, GLdouble(r.size.height), -1, 1);
            
            glMatrixMode(UInt32(GL_MODELVIEW));
            glLoadIdentity();
            
            _lastBounds = r;
            
            self.viewBoundsDidChange(r)
        }
    }
    
    func displayProfileChanged() -> Void {
    
        self.cglContext = self.openGLContext?.cglContextObj
        
        if(self.pf == nil)
        {
            self.pf = self.pixelFormat
            if (self.pf == nil) {
                self.pf = CanvasImageView.defaultPixelFormat()
            }
        }
        
        CGLLockContext(self.cglContext!)
        
            // Create a new CIContext using the new output color space
            let object = NSUserDefaultsController.shared().defaults.object(forKey: "useSoftwareRenderer")
            if self._contextOptions == nil
            {
                self._contextOptions?.setObject(object!, forKey: kCIContextUseSoftwareRenderer as NSCopying)
            } else {
                self._contextOptions = NSMutableDictionary(object: object!, forKey: kCIContextUseSoftwareRenderer as NSCopying)
            }
        
            // For 10.6 onwards we use the new API but do not pass in a colorspace as.
            // Since the cgl context will be rendered to the display, it is valid to rely on CI to get the colorspace from the context.
            
        self._context = CIContext(cglContext: self.cglContext!, pixelFormat: self.pf?.cglPixelFormatObj, colorSpace: nil, options: self._contextOptions as? [String : Any])

        CGLUnlockContext(self.cglContext!)
    }

    
    var delegate: CanvasImageViewDelegate?


    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }
    
    private func commonSetup() {
        layerContentsRedrawPolicy = .onSetNeedsDisplay
    }

    override func draw(_ dirtyRect: NSRect) {
        
        var ir: CGRect? = nil
        var rr: CGRect? = nil
        
        self.openGLContext?.makeCurrentContext()
        if self._context == nil {
            self.displayProfileChanged()
        }
        
        ir = CGRect(x: dirtyRect.origin.x, y: dirtyRect.origin.y, width: dirtyRect.width, height: dirtyRect.height).integral
        
        self.updateMatrices()
        
        /* Clear the specified subrect of the OpenGL surface then
         * render the image into the view. Use the GL scissor test to
         * clip to * the subrect. Ask CoreImage to generate an extra
         * pixel in case * it has to interpolate (allow for hardware
         * inaccuracies) */
        
        rr = ir?.insetBy(dx: -1.0, dy:  -1.0).intersection(self._lastBounds!)
        glScissor(GLint(ir!.origin.x), GLint(ir!.origin.y), GLsizei(ir!.size.width), GLsizei(ir!.size.height));
        glEnable(GLenum(GL_SCISSOR_TEST));
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        
        if _ciImage == nil {
            let imageData = image?.tiffRepresentation
            let sourceData = CGImageSourceCreateWithData(imageData! as CFData, nil)
            let cgImage: CGImage? = CGImageSourceCreateImageAtIndex(sourceData!, 0, nil)
            let ciImage: CIImage? = CIImage(cgImage: cgImage!)
            
            self._context?.draw(ciImage!, in: rr!, from: rr!)
        } else {
            self._context?.draw(self._ciImage!, in: rr!, from: rr!)
        }
        
        glDisable(GLenum(GL_SCISSOR_TEST))
        
        /* Flush the OpenGL command stream. If the view is double
         * buffered this should be replaced by [[self openGLContext]
         * flushBuffer]. */
        
        glFlush ();
    }
    
    override var intrinsicContentSize: NSSize {
        get {
            if let image = image {
                return image.size
            } else {
                return NSSize(width: 800, height: 600)
            }
        }
        
    }
    
    private func sendImageChanged() {
        if let delegate = delegate {
            delegate.canvasImageView(self, didChangeImage: image)
        }
    }
    
    // Move the scrollview when the mouse moves
    private func trackForMove(event mouseDownEvent: NSEvent) {
        let window = self.window!
        let startingPoint = mouseDownEvent.locationInWindow
        let contentClipView = enclosingScrollView!.contentView
        let startingOrigin = contentClipView.bounds.origin
        
        window.trackEvents(matching: [.leftMouseDragged, .leftMouseUp], timeout:NSEventDurationForever, mode: .defaultRunLoopMode) { event, stop in
            let currentPoint = event.locationInWindow
            let xMoved = startingPoint.x - currentPoint.x // move to the right moves the contents the opposite direction
            let yMoved = currentPoint.y - startingPoint.y
            let newOrigin = NSPoint(x: startingOrigin.x + xMoved, y: startingOrigin.y + yMoved)
            contentClipView.scroll(to: newOrigin)
            
            if event.type == .leftMouseUp {
                stop.pointee = true
            }
        }
    }
    
    // "draw" on the image
    private func trackForDraw(event mouseDownEvent: NSEvent) {
        // Draw on a copy of the image
        guard let image = image?.copy() as? NSImage else { return }
        
        let window = self.window!
        var lastPoint = convert(mouseDownEvent.locationInWindow, from: nil)
        
        window.trackEvents(matching: [.leftMouseDragged, .leftMouseUp], timeout:NSEventDurationForever, mode: .defaultRunLoopMode) { event, stop in
            
            let currentPoint = self.convert(event.locationInWindow, from: nil)
            
            image.lockFocusFlipped(true)
            
            let path = NSBezierPath()
            path.move(to: lastPoint)
            path.line(to: currentPoint)
            
            let color = NSColor.black
            color.set()
            path.lineWidth = 4.0 // easy to see
            
            path.stroke()
            
            image.unlockFocus()
            lastPoint = currentPoint
            
            // Refresh what we are showing
            self.image = image
            self.needsDisplay = true
            
            if event.type == .leftMouseUp {
                stop.pointee = true
            }
        }
        
        // Tell the delegate the image changed only once at the end of the mouse tracking
        sendImageChanged()
    }
}

// We don't want to tie our implementation to any specific controller, and instead use delegation via a protocol
protocol CanvasImageViewDelegate {
    func canvasImageView(_ canvasImageView: CanvasImageView, didChangeImage image: NSImage?)
}


// Provide a default implementation to make the protocol implementation optional
extension CanvasImageViewDelegate {
    func canvasImageView(_ canvasImageView: CanvasImageView, didChange image: NSImage?) {
    }
}
