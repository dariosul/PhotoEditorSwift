/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The CanvasImageView is a basic NSView subclass. It demonstrates manually drawing an image inside of a normal draw() method, along with event tracking. The event tracking moves the clip view that contains the image, or allows drawing on top of it.
*/


import Cocoa

class CanvasImageView: NSView {
    
    // PhotoDocumentWindowController also has an EditMode, but this view only supports two styles of editing: moving and drawing.
//    enum EditMode: Int {
//        case move
//        case draw
//    }
    
    var image: NSImage? {
        didSet(oldImage) {
            if (oldImage != image) {
                needsDisplay = true
                invalidateIntrinsicContentSize()
            }
        }
    }
    // these will receive notification about points on mouse draw
//    private let mouseDrawSubscribers = NSHashTable<AnyObject>.weakObjects()
    
    var delegate: CanvasImageViewDelegate?
    
//    func addSubscriber(_ subscriber: MouseDraw) {
//        mouseDrawSubscribers.add(subscriber)
//    }
    
//    func removeSubscriber(_ subscriber: MouseDraw) {
//        mouseDrawSubscribers.remove(subscriber)
//    }

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
        if let image = image {
            image.draw(in: bounds)
        }
    }
    
    // Make the origin be the top left
    override var isFlipped: Bool {
        return true
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
    
//    private func getEditMode() -> EditMode {
//        if let delegate = delegate {
//            return delegate.getEditMode(in: self)
//        } else {
//            return .move
//        }
//    }
    
    private func sendImageChanged() {
        if let delegate = delegate {
            delegate.canvasImageView(self, didChangeImage: image)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
//        switch getEditMode() {
//            case .move:
            mouseDragged(with: event)
//                trackForFilters(event: event)
                //trackForMove(event: event)
                //fallthrough
            
//            case .draw:
//                trackForDraw(event: event)
//        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        
//        {
//            CIFilter *brushFilter = self.brushFilter;
//
//            NSPoint  loc = [self convertPoint:[event locationInWindow] fromView:nil];
//            [brushFilter setValue:@(self.brushSize) forKey:@"inputRadius1"];
//
//            CIColor *cicolor = [[CIColor alloc] initWithColor:self.color];
//            [brushFilter setValue:cicolor forKey:@"inputColor0"];
//
//            CIVector *inputCenter = [CIVector vectorWithX:loc.x Y:loc.y];
//            [brushFilter setValue:inputCenter forKey:@"inputCenter"];
//
//
//            CIFilter *compositeFilter = self.compositeFilter;
//
//            [compositeFilter setValue:[brushFilter valueForKey:@"outputImage"] forKey:@"inputImage"];
//            [compositeFilter setValue:[self.imageAccumulator image] forKey:@"inputBackgroundImage"];
//
//            CGFloat brushSize = self.brushSize;
//            CGRect rect = CGRectMake(loc.x-brushSize, loc.y-brushSize, 2.0*brushSize, 2.0*brushSize);
//
//            [self.imageAccumulator setImage:[compositeFilter valueForKey:@"outputImage"] dirtyRect:rect];
//            [self setImage:[self.imageAccumulator image] dirtyRect:rect];
//        }
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
    
    // Record the points when the mouse moves
    private func trackForFilters(event mouseDownEvent: NSEvent) {
        
        let window = self.window!
        let startingPoint = self.convert(mouseDownEvent.locationInWindow, from: nil)
        var points = [startingPoint]
        
        window.trackEvents(matching: [.leftMouseDragged, .leftMouseUp], timeout:NSEventDurationForever, mode: .defaultRunLoopMode) { event, stop in
            
            let currentPoint = self.convert(event.locationInWindow, from: nil)
            points.append(currentPoint)
            
            if event.type == .leftMouseUp {
                stop.pointee = true
            }
        }
        
        // send the update to subscriber
        for object in delegate!.getMouseDrawSubscribers().objectEnumerator(){
            guard let subscriber = object as? MouseDraw else {continue}
            subscriber.updateBrushPoints(mousePoints: points)
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


protocol MouseDraw: class {
    func updateBrushPoints(mousePoints points: [CGPoint])->Void
}


// We don't want to tie our implementation to any specific controller, and instead use delegation via a protocol
protocol CanvasImageViewDelegate {
    func canvasImageView(_ canvasImageView: CanvasImageView, didChangeImage image: NSImage?)
//    func getEditMode(in canvasImageView: CanvasImageView) -> CanvasImageView.EditMode
    
    func getMouseDrawSubscribers() -> NSHashTable<AnyObject>
    
    func addSubscriber(_ subscriber: MouseDraw)
    
    func removeSubscriber(_ subscriber: MouseDraw)
}


// Provide a default implementation to make the protocol implementation optional
extension CanvasImageViewDelegate {
    func canvasImageView(_ canvasImageView: CanvasImageView, didChange image: NSImage?) {
    }
//    func getEditMode(in canvasImageView: CanvasImageView) -> CanvasImageView.EditMode {
//        return CanvasImageView.EditMode.move
//    }
}
