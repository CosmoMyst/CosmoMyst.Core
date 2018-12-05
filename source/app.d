import monomyst.core.window;

void main ()
{
    import std.stdio : writeln;

    Window window = new Window ();

    while (!window.shouldClose)
    {
        window.pollEvents ();
    }
}
