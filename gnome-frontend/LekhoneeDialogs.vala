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
