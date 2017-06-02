# sQtch (/skɛtʃ/) Qt Hackathon 2013 version

The idea here was to try to build a sketching, diagramming and UI prototyping
tool in Qt Quick, in a 24-hour hackathon.

- There's a palette of pre-built objects (stencils in Visio terminology)
  which are used as prototypes: you can populate your drawing by cloning them
  into the drawing.  Flowchart shapes or UML shapes for example 
  (but I didn't implement nearly as many as there could be).

- You can draw lines and curves (intended to be connectors eventually)
  with the stylus, assuming you've got a Wacom tablet or something similar,
  which generates QTabletEvents.

- Those lines and curves are automatically simplified.

- So after a while you have a bunch of QQuickItems in your drawing, in memory.
  Save the drawing by persisting them to a QML file.  Now you can run the
  qml file with the qml runtime: you don't need sQtch anymore, just to view it.

- If we put some QtQuick.Controls into the palette too, you can actually use
  this as a UI prototyping tool: like Balsamiq, except it generates QML.
  A designer could sketch a rough UI and a developer could refine it into
  a functional application.

- Stretch goal: try to recognize closed shapes and replace them with the
  appropriate stencil shapes, so maybe you could draw a flowchart freehand
  and end up with a nice clean object-oriented flowchart where the symbols
  can be dragged around and the connectors stay connected.  (Not achieved,
  but QML is just begging to be used that way.)

There were several obstacles:

## Lack of Wacom tablet support and lack of shape-drawing support in Qt Quick

This is not fixed to this day... but maybe we'll get there in Qt 5.10 or 5.11.

The difficulty stems from the lack of a common ancestor among QMouseEvent,
QTouchEvent and QTabletEvent, which has enough information for QQuickWindow to
be able to deliver it with shared logic.  This is why QQuickWindow had separate
delivery logic for mouse and touch events (with their own independent bugs) and
doing all that again for tablet events was impractical.  (But for this
hackathon I went ahead and did it anyway, the ugly way).  But we are fixing
that a bit more nicely in Qt 5.10 (hopefully): currently in the
wip/pointerhandler branch of qtdeclarative, soon to be merged to dev branch.
Since the QEvents themselves are too independent, we had to wrap them in
a class called QQuickPointerEvent, and deliver the wrapper, which holds the
original event inside.  This way the delivery logic can be shared for
all three.  (But the QTabletEvent support is not actually done yet.)

Well, so maybe we can deliver QTabletEvent... next thing is what to do with it.
Here we want to draw something freehand, and refine it later.  It's hard to
think of a good declarative API for that... except declare some sort of
TabletSketchArea which either provides just the events and then you use
a JS API to render the strokes; or, the TabletSketchArea could maybe populate
strokes into some C++-based drawing model on its own.  In this hack I took
the former approach.  https://github.com/qtproject/playground-scenegraph
provides Qt.labs.shapes, and it has a JS API, so it was possible to handle
the tablet events and draw shapes piecewise.  Alternatively it would be
possible to use the Canvas API.  That can provide antialiasing, but it's
not efficient: the CPU does all the rendering work, and the GPU is only
used to blit the resulting texture.  (Why? because we still haven't taught
QTriangulator how to generate vertices for portable vertex antialiasing.
It's a tough problem.  I have a solution for the limited context of
2D line charts here: https://github.com/ec1oud/qqchart and in that case,
the vertex AA calculations are done in the vertex shader.)

Finally, after so many years in which QML has had things like
https://doc.qt.io/qt-5/qml-qtquick-pathsvg.html which have only been useful for
describing a Path in a PathView (for dragging other items along a path, not for
rendering the path itself), we are on track to have a rendering solution in
5.10.  But so far, the JS API still isn't on track.  I'll try to figure out
what else I can do instead, on other branches of this repo.  And antialiasing
is not possible unless you turn on MSAA for the whole scene.  I didn't try
to solve the AA problem in this hackathon, either.  In 2013 I didn't understand
well enough how to even start on that.

## QML is not designed as a serializable language

A wonderful thing about most (all?) variants of Lisp is that you can build
up an AST of S-expressions, and then you can eval it.  Code is data and data
is code.  You might get that tree by reading a source file, or by programmatically
constructing it, one new expression at a time.  (This is how a compiler is built.)
And serialization is trivial: just pretty-print the AST.

In most other languages, not so much... the compiler or interpreter is a
black box, the AST is not public API, and you need some sort of code model to
allow one program to manipulate another.  For example, Qt Creator nowadays
borrows a model from Clang in order to understand your C++ code, to do syntax
highlighting, pre-checking for warnings, refactoring etc (that's the level at
which I understand, not having studied that aspect of it).

I tried to force-fit a solution: make QQuickItem recursively serializable, for
certain properties only.  Since this was a hackathon, I modified code
in qtdeclarative with patches which are unlikely to ever be integrated.
This version of sQtch depends on them.  (So you probably won't have much
luck getting this to run.)

This is the same problem that the Qt Quick Designer faces: if you place a
Rectangle into the scene for example, and you interactively manipulate it,
property bindings are changed by that manipulation.  You can set x and y to
hard-coded qreal values, but what if they are instead bound to QML expressions?
Expressions aren't fundamentally serializable either - we'd have to add that to
the V4 engine, I guess.  Nowadays I should study how Qt Quick Designer actually
does it.  But it was immature in 2013: it was too hard to do it in Qt Quick
2.0, so they were rendering a manipulable approximation of the scene rather
than the actual scene.

Anyway, it all came together and sortof worked... but it was a dead end.  Also
didn't really inspire anyone (other than me) to actually fix any of the issues
properly either, AFAIK.

