// this program draws a Sierpinski triangle recursively using Fiber
import arsd.simpledisplay : Color, Point, ScreenPainter, SimpleWindow;
import core.thread : Fiber;

void main()
{
    SimpleWindow window = new SimpleWindow(800, 800, "Sierpinski Triangle");
    // we create and draw the initial triangle, it will have sides of 900 pixels
    Triangle firstTriangle = Triangle(Point(50, 703), Point(400, 97), Point(750, 703));
    {
        ScreenPainter painter = window.draw();
        painter.clear(Color.black());
        painter.outlineColor = Color.yellow();
        painter.drawLine(firstTriangle.leftVertex, firstTriangle.rightVertex);
        painter.drawLine(firstTriangle.rightVertex, firstTriangle.upperVertex);
        painter.drawLine(firstTriangle.upperVertex, firstTriangle.leftVertex);
    }
    // here we finally begin dividing the triangle recursively
    Fiber fiberObject = new Fiber({divide(firstTriangle, window);});
    window.eventLoop(10,
    {
        // here we just keep calling the fiber object over and over until it's done
        if (fiberObject.state != fiberObject.state.TERM)
            fiberObject.call();
    });
}

// this is the recursive routine which will divide the father triangle into 4 triangles
void divide(Triangle fatherTriangle, SimpleWindow programWindow)
{
    Fiber.yield();
    // we find the 3 midpoints of the father triangle
    Point[3] midPoints = findMidpoints(fatherTriangle);
    // we draw the lines to divide the father triangle, it's inside a scope so the GUI gets flushed right away
    {
        ScreenPainter painter = programWindow.draw();
        painter.outlineColor = Color.yellow();
        painter.drawLine(midPoints[0], midPoints[2]);
        painter.drawLine(midPoints[2], midPoints[1]);
        painter.drawLine(midPoints[1], midPoints[0]);
    }
    // we define the 3 new triangles with their vertices
    Triangle leftNewTriangle = Triangle(fatherTriangle.leftVertex, midPoints[0], midPoints[1]);
    Triangle upperNewTriangle = Triangle(midPoints[0], fatherTriangle.upperVertex, midPoints[2]);
    Triangle rightNewTriangle = Triangle(midPoints[1], midPoints[2], fatherTriangle.rightVertex);
    // se o lado dos novos triangulos for menor do que 3 pixels então preencha ele fazendo uma função que desenha linhas pelos pixels dele todo
    // if the new triangles have sides smaller or equal than 5 pixels than just fill them instead of dividing them again
    if (leftNewTriangle.rightVertex.x - leftNewTriangle.leftVertex.x <= 5)
        fillTriangle(leftNewTriangle, programWindow), fillTriangle(upperNewTriangle, programWindow), fillTriangle(rightNewTriangle, programWindow);
    else
        // now we start over recursively for each new triangle
        divide(leftNewTriangle, programWindow), divide(upperNewTriangle, programWindow), divide(rightNewTriangle, programWindow);
}

// this function calculate the midpoints of father triangle
Point[3] findMidpoints(Triangle fatherTriangle)
{
    Point leftMidpoint, upperMidpoint, rightMidpoint;
    leftMidpoint = Point((fatherTriangle.leftVertex.x + fatherTriangle.upperVertex.x) / 2, (fatherTriangle.upperVertex.y + fatherTriangle.leftVertex.y) / 2);
    upperMidpoint = Point(fatherTriangle.upperVertex.x, fatherTriangle.leftVertex.y);
    rightMidpoint = Point((fatherTriangle.upperVertex.x + fatherTriangle.rightVertex.x) / 2, (fatherTriangle.upperVertex.y + fatherTriangle.leftVertex.y) / 2);
    return [leftMidpoint, upperMidpoint, rightMidpoint];
}

// this routine will paint the inside of the triangle once it becomes too small to be divided any further
void fillTriangle(Triangle currentTriangle, SimpleWindow programWindow)
{
    ScreenPainter painter = programWindow.draw();
    painter.outlineColor = Color.yellow();
    // we just draw lines connecting the upper vertex to all the points of the base of the triangle
    foreach (baseX; currentTriangle.leftVertex.x .. currentTriangle.rightVertex.x)
        painter.drawLine(currentTriangle.upperVertex, Point(baseX, currentTriangle.leftVertex.y));
}

// this struct will represent a triangle with the 3 vertices
struct Triangle
{
    Point leftVertex, upperVertex, rightVertex;

    this (Point leftVertex, Point upperVertex, Point rightVertex)
    {
        this.leftVertex = leftVertex, this.upperVertex = upperVertex, this.rightVertex = rightVertex;
    }
}
