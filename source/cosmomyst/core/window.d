module cosmomyst.core.window;

import xcb.xcb;

/++
 + A wrapper class around XCB
 +/
public class XCBWindow
{
    /++
     + If the window is open.
     +/
    @property public bool open () { return _open; }
    private bool _open = true;

    /++
     + XCB Connection
     +/
    @property public xcb_connection_t* connection () { return _connection; }
    private xcb_connection_t* _connection;

    /++
     + XCB Window
     +/
    @property public xcb_window_t window () { return _window; }
    private xcb_window_t _window;

    private xcb_generic_event_t* currentEvent;

    private xcb_intern_atom_reply_t* reply2;

    /++
     + Creates a new window with the specified width and height
     +/
    this (ushort width, ushort height)
    {
        import std.stdio : writeln;
        import core.runtime : Runtime;

        int screenNumber;

        _connection = xcb_connect (null, &screenNumber);

        if (xcb_connection_has_error (_connection))
        {
            throw new Exception ("Failed to establish an XCB connection.");
        }

        const xcb_setup_t* setup = xcb_get_setup (_connection);
        xcb_screen_iterator_t iterator = xcb_setup_roots_iterator (setup);

        for (int i; i < screenNumber; i++)
        {
            xcb_screen_next (&iterator);
        }

        xcb_screen_t* screen = iterator.data;

        _window = xcb_generate_id (_connection);
        
        const uint values = XCB_EVENT_MASK_EXPOSURE;
        
        xcb_create_window (_connection,
                           XCB_COPY_FROM_PARENT,
                           _window,
                           screen.root,
                           0, 0,
                           width, height,
                           0,
                           XCB_WINDOW_CLASS_INPUT_OUTPUT,
                           screen.root_visual,
                           XCB_CW_EVENT_MASK, &values);

        xcb_intern_atom_cookie_t cookie = xcb_intern_atom (_connection, 1, 12, "WM_PROTOCOLS");
        xcb_intern_atom_reply_t* reply = xcb_intern_atom_reply (_connection, cookie, null);
        xcb_intern_atom_cookie_t cookie2 = xcb_intern_atom (_connection, 0, 16, "WM_DELETE_WINDOW");
        reply2 = xcb_intern_atom_reply (_connection, cookie2, null);

        xcb_change_property (_connection, XCB_PROP_MODE_REPLACE, _window, reply.atom, 4, 32, 1, &reply2.atom);

        xcb_map_window (_connection, _window);

        xcb_flush (_connection);
    }

    /++
     + Polls all XCB events and handles them
     +/
    void pollEvents ()
    {
        import std.stdio : writefln;

        while ((currentEvent = xcb_wait_for_event (_connection)) !is null)
        {
            switch (currentEvent.response_type & ~0x80)
            {
                case XCB_CLIENT_MESSAGE:
                {
                    if ((cast (xcb_client_message_event_t*) currentEvent).data.data32 [0] == reply2.atom)
                    {
                        _open = false;
                        return;
                    }
                } break;
                default:
                {
                } break;
            }
        }
    }

    ~this ()
    {
        xcb_disconnect (_connection);
    }
}
