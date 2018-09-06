module monomyst.core.window;

import xcb.xcb;

public class Window
{
    private xcb_connection_t* connection;

    this ()
    {
        import std.stdio : writeln;

        int screenNumber;

        connection = xcb_connect (null, &screenNumber);

        const xcb_setup_t* setup = xcb_get_setup (connection);
        xcb_screen_iterator_t iterator = xcb_setup_roots_iterator (setup);

        for (int i; i < screenNumber; i++)
            xcb_screen_next (&iterator);

        xcb_screen_t* screen = iterator.data;
    
        writeln ("Informations of screen ", screen.root);
        writeln ("Width ", screen.width_in_pixels);
        writeln ("Height ", screen.height_in_pixels);
        writeln ("White pixel ", screen.white_pixel);
        writeln ("Black pixel ", screen.black_pixel);

        xcb_window_t window = xcb_generate_id (connection);
        xcb_create_window (connection,
                           XCB_COPY_FROM_PARENT,
                           window,
                           screen.root,
                           0, 0,
                           150, 150,
                           10,
                           XCB_WINDOW_CLASS_INPUT_OUTPUT,
                           screen.root_visual,
                           0, null);

        xcb_map_window (connection, window);

        xcb_flush (connection);
    }

    ~this ()
    {
        xcb_disconnect (connection);
    }
}
