using Gtk;

public class GenericDialog: Dialog {
    private Entry link_entry;
    private Widget apply_bttn;
    
    public signal void send_link(string mesaage);
    
    public GenericDialog(string text) {
        this.title = text;
        this.border_width = 5;
        set_default_size (350, 100);
        create_widgets(text);

    }
    
    private void create_widgets(string text){
    
        //setup widgets
        this.link_entry = new Entry();
        var link_label = new Label.with_mnemonic (text);
        link_label.mnemonic_widget = this.link_entry;
        
        var hbox = new HBox (false, 20);
        hbox.pack_start (link_label, false, true, 0);
        hbox.pack_start (this.link_entry, true, true, 0);
        this.vbox.pack_start (hbox, false, true, 0);
        this.vbox.spacing = 10;
        
        add_button (STOCK_CLOSE, ResponseType.CLOSE);
        this.apply_bttn = add_button (STOCK_APPLY, ResponseType.APPLY);
        this.response.connect (on_response);

    }
    
    
    private void on_response (Dialog source, int response_id) {
        switch (response_id) {
        case ResponseType.APPLY:
            send_link(this.link_entry.get_text());
            destroy();
            break;
        case ResponseType.CLOSE:
            destroy();
            break;
        }
    }


}


public class ConfigDialog: Dialog {

    private Widget apply_bttn;
    public Entry user_entry;
    public Entry server_entry;
    public Entry pass_entry;
    public string filename;
    public string server;
    public string username;
    
    public signal void config_done(string ss, string uu, string pp);
    
    public ConfigDialog() {
        this.title = "Preferences";
        this.border_width = 5;
        set_default_size (350, 150);
        server = "";
        username = "";
        
        filename = Environment.get_home_dir() + "/.lekhonee.config";
        KeyFile keyf = new KeyFile();
        try{
            keyf.load_from_file(filename,KeyFileFlags.NONE);
            server = keyf.get_string("details","server");
            username = keyf.get_string("details","username");
        }catch(Error e){
            debug(e.message);
        }
        
        create_widgets(server,username);

    }
    
    private void create_widgets(string s, string u){
    
        //setup widgets
        
        var link_label = new Label.with_mnemonic ("Server");
        server_entry = new Entry();
        server_entry.set_text(s);
        link_label.mnemonic_widget = server_entry;
        
        var hbox = new HBox (false, 20);
        hbox.pack_start (link_label, false, true, 0);
        hbox.pack_start (server_entry, true, true, 0);

        var user_label = new Label.with_mnemonic ("Username");
        user_entry = new Entry();
        user_entry.set_text(u);
        user_label.mnemonic_widget = user_entry;
        
        var hbox1 = new HBox (false, 20);
        hbox1.pack_start (user_label, false, true, 0);
        hbox1.pack_start (user_entry, true, true, 0);

        
        var pass_label = new Label.with_mnemonic ("Password");
        pass_entry = new Entry();
        pass_entry.set_invisible_char('*');
        pass_entry.set_visibility(false);
        
        pass_label.mnemonic_widget = pass_entry;
        
        var hbox2 = new HBox (false, 20);
        hbox2.pack_start (pass_label, false, true, 0);
        hbox2.pack_start (pass_entry, true, true, 0);

        
        
        
        
        this.vbox.pack_start (hbox, false, true, 0);
        this.vbox.pack_start (hbox1, false, true, 0);
        this.vbox.pack_start (hbox2, false, true, 0);
        this.vbox.spacing = 10;
        
        add_button (STOCK_CANCEL, ResponseType.CANCEL);
        this.apply_bttn = add_button (STOCK_OK, ResponseType.OK);
        this.response.connect (on_response);

    }
    
    
    private void on_response (Dialog source, int response_id) {
        switch (response_id) {
        case ResponseType.OK:
            server = server_entry.get_text();
            username = user_entry.get_text();
            string password = pass_entry.get_text();
            config_done(server,username,password);
            destroy();
            break;
        case ResponseType.CANCEL:
            destroy();
            break;
        }
    }


}
