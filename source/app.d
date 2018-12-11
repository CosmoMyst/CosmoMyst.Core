void main ()
{
    import std.stdio : writeln;
    import cosmomyst.core : Window;

    Window window = new Window (400, 400);

    while (!window.shouldClose)
    {
        window.pollEvents ();
    }
}
