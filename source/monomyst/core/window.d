module monomyst.core.window;

import xcb.xcb;

public class Window
{
    @property bool shouldClose () { return _shouldClose; }
    private bool _shouldClose;

    @property xcb_connection_t* xcbconnection () { return connection; }
    private xcb_connection_t* connection;

    @property xcb_window_t xcbwindow () { return window; }
    private xcb_window_t window;

    private xcb_generic_event_t* currentEvent;

    private xcb_intern_atom_reply_t* reply2;

    this ()
    {
        import std.stdio : writeln;
        import core.runtime : Runtime;

        int screenNumber;

        connection = xcb_connect (null, &screenNumber);

        if (xcb_connection_has_error (connection))
        {
            writeln ("Error while openning a window.");
            return;
        }

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

        window = xcb_generate_id (connection);
        
        const uint values = XCB_EVENT_MASK_EXPOSURE;
        
        xcb_create_window (connection,
                           XCB_COPY_FROM_PARENT,
                           window,
                           screen.root,
                           0, 0,
                           400, 400,
                           0,
                           XCB_WINDOW_CLASS_INPUT_OUTPUT,
                           screen.root_visual,
                           XCB_CW_EVENT_MASK, &values);

        xcb_intern_atom_cookie_t cookie = xcb_intern_atom (connection, 1, 12, "WM_PROTOCOLS");
        xcb_intern_atom_reply_t* reply = xcb_intern_atom_reply (connection, cookie, null);
        xcb_intern_atom_cookie_t cookie2 = xcb_intern_atom (connection, 0, 16, "WM_DELETE_WINDOW");
        reply2 = xcb_intern_atom_reply (connection, cookie2, null);

        xcb_change_property (connection, XCB_PROP_MODE_REPLACE, window, reply.atom, 4, 32, 1, &reply2.atom);

        xcb_map_window (connection, window);

        xcb_flush (connection);
    }

    void pollEvents ()
    {
        import std.stdio : writefln;

        while ((currentEvent = xcb_wait_for_event (connection)) !is null)
        {
            switch (currentEvent.response_type & ~0x80)
            {
                case XCB_CLIENT_MESSAGE:
                {
                    if((cast (xcb_client_message_event_t*) currentEvent).data.data32 [0] == reply2.atom)
                    {
                        _shouldClose = true;
                        return;
                    }
                } break;
                default:
                {
                    writefln ("Event: %s", currentEvent.response_type);
                } break;
            }
        }
    }

    ~this ()
    {
        xcb_disconnect (connection);
    }
}
