void main ()
{
    import std.stdio : writeln;
    import cosmomyst.core : XCBWindow;

    XCBWindow window = new XCBWindow (400, 400);

    while (window.open)
    {
        window.pollEvents ();
    }
}
