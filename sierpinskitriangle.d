// This software draws a Sierpinski triangle recursively using the fiber feature of Dlang.

import arsd.simpledisplay : Color, Point, ScreenPainter, SimpleWindow;
import core.thread : Fiber;

// this struct will represent a triangle with its 3 vertices
struct Triangle
{
    // these are the points of the vertices of the triangle
    Point leftVertex, upperVertex, rightVertex;

    // this is the constructor of the struct
    this (Point leftVertex, Point upperVertex, Point rightVertex)
    {
        // define all the points declared above
        this.leftVertex = leftVertex, this.upperVertex = upperVertex, this.rightVertex = rightVertex;
    }
}

// this function calculate the midpoints of father triangle
Point[3] findMidpoints(Triangle fatherTriangle)
{
    // create the 3 midpoints
    Point leftMidpoint, upperMidpoint, rightMidpoint;
    // calculate the coordinates of the left midpoint (it is the left vertex of the child triangle)
    leftMidpoint = Point((fatherTriangle.leftVertex.x + fatherTriangle.upperVertex.x) / 2,
                         (fatherTriangle.upperVertex.y + fatherTriangle.leftVertex.y) / 2);
    // calculate the coordinates of the upper midpoint (it is the upper vertex of the child triangle)
    upperMidpoint = Point(fatherTriangle.upperVertex.x, fatherTriangle.leftVertex.y);
    // calculate the coordinates of the right midpoint (it is the right vertex of the child triangle)
    rightMidpoint = Point((fatherTriangle.upperVertex.x + fatherTriangle.rightVertex.x) / 2,
                          (fatherTriangle.upperVertex.y + fatherTriangle.leftVertex.y) / 2);

    // return the array with all 3 points
    return [leftMidpoint, upperMidpoint, rightMidpoint];
}

// this is the recursive function which will divide the father triangle into 4 triangles
void divide(Triangle fatherTriangle, SimpleWindow programWindow)
{
    // stop the fiber and wait until it is called again
    Fiber.yield();
    // find the 3 midpoints of the father triangle
    Point[3] midPoints = findMidpoints(fatherTriangle);

    // we draw the lines to divide the father triangle, it's inside a scope so the GUI gets flushed right away
    {
        // create the painter
        ScreenPainter painter = programWindow.draw();
        // get the yellow color
        painter.outlineColor = Color.yellow();
        // draw the first line to divide it into 4 smaller triangles
        painter.drawLine(midPoints[0], midPoints[2]);
        // draw the second line to divide it into 4 smaller triangles
        painter.drawLine(midPoints[2], midPoints[1]);
        // draw the third line to divide it into 4 smaller triangles
        painter.drawLine(midPoints[1], midPoints[0]);
    }

    // define the 3 child triangles with their vertices
    Triangle leftNewTriangle = Triangle(fatherTriangle.leftVertex, midPoints[0], midPoints[1]),
             upperNewTriangle = Triangle(midPoints[0], fatherTriangle.upperVertex, midPoints[2]),
             rightNewTriangle = Triangle(midPoints[1], midPoints[2], fatherTriangle.rightVertex);

    // if the new triangles have sides smaller than or equal to 5 pixels
    if (leftNewTriangle.rightVertex.x - leftNewTriangle.leftVertex.x <= 5)
        // just fill them instead of dividing them again, this is the base case
        fillTriangle(leftNewTriangle, programWindow), fillTriangle(upperNewTriangle, programWindow), fillTriangle(rightNewTriangle, programWindow);
    // if the sides are bigger than 5 pixels
    else
        // start over recursively, for each new triangle
        divide(leftNewTriangle, programWindow), divide(upperNewTriangle, programWindow), divide(rightNewTriangle, programWindow);
}

// this function will paint the inside of the triangle once it becomes too small to be divided any further
void fillTriangle(Triangle currentTriangle, SimpleWindow programWindow)
{
    // create the painter
    ScreenPainter painter = programWindow.draw();
    // get the yellow color
    painter.outlineColor = Color.yellow();

    // use a loop to draw several lines to fill the inside of the triangle
    foreach (baseX; currentTriangle.leftVertex.x .. currentTriangle.rightVertex.x)
        // draw a line connecting the upper vertex to one of the points of the base of the triangle
        painter.drawLine(currentTriangle.upperVertex, Point(baseX, currentTriangle.leftVertex.y));
}

void main()
{
    // create the window for the GUI
    SimpleWindow window = new SimpleWindow(800, 800, "Sierpinski Triangle");

    // create the initial triangle, it will have sides of 900 pixels
    Triangle firstTriangle = Triangle(Point(50, 703), Point(400, 97), Point(750, 703));

    // draw the initial triangle, it's inside a scope so the GUI gets flushed right away
    {
        // create the painter
        ScreenPainter painter = window.draw();
        // clear the GUI
        painter.clear(Color.black());
        // get the yellow color
        painter.outlineColor = Color.yellow();
        // draw the first side of the triangle
        painter.drawLine(firstTriangle.leftVertex, firstTriangle.rightVertex);
        // draw the second side of the triangle
        painter.drawLine(firstTriangle.rightVertex, firstTriangle.upperVertex);
        // draw the third side of the triangle
        painter.drawLine(firstTriangle.upperVertex, firstTriangle.leftVertex);
    }

    // create the fiber and call the function which will divide the triangle recursively
    Fiber fiberObject = new Fiber({divide(firstTriangle, window);});

    // start the event loop
    window.eventLoop(10,
    {
        // if the fiber hasn't finished yet
        if (fiberObject.state != fiberObject.state.TERM)
            // call the fiber again, to resume the work
            fiberObject.call();
    });
}
