void main ()
{
    import std.stdio : writeln;
    import cosmomyst.core : Window;

    Window window = new Window ();

    while (!window.shouldClose)
    {
        window.pollEvents ();
    }
}
