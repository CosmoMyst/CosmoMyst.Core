void main ()
{
    import std.stdio : writeln;
    import monomyst.core : Window;

    Window window = new Window ();

    while (!window.shouldClose)
    {
        window.pollEvents ();
    }
}
