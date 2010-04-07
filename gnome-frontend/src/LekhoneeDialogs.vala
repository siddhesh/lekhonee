/* LekhoneeDialogs.vala
 *
 * Copyright (C) 2010  Kushal Das <kushal@fedoraproject.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 *
 */
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
    public CheckButton advert;
    public string filename;
    public string server;
    public string username;
    public bool ad;
    public KeyFile keyf;
    
    public signal void config_done(string ss, string uu, string pp, bool aa);
    
    public ConfigDialog() {
        this.title = _("Preferences");
        this.border_width = 5;
        set_default_size (350, 150);
        server = "";
        username = "";
        
        filename = Environment.get_home_dir() + "/.lekhonee.config";
        keyf = new KeyFile();
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
        var box = new HBox(false, 0);
        
        var link_label = new Label.with_mnemonic ("Server: ");
        server_entry = new Entry();
        if(s!="")
            server_entry.set_text(s);
        else
            server_entry.set_text("http://userserver.org/xmlrpc.php");
        link_label.mnemonic_widget = server_entry;

        var table = new Table(3, 2, false);

        table.set_row_spacings(5);
        table.set_col_spacings(5);

        box.pack_end(link_label, false, false, 5);
        table.attach(box, 0, 1, 0, 1, AttachOptions.FILL, AttachOptions.FILL, 0, 0);
        table.attach(server_entry, 1, 2, 0, 1, AttachOptions.FILL, AttachOptions.FILL, 0, 0);
        
        var user_label = new Label.with_mnemonic ("Username: ");
        user_entry = new Entry();
        user_entry.set_text(u);
        user_label.mnemonic_widget = user_entry;
        
        box = new HBox(false, 0);
        box.pack_end(user_label, false, false, 5);
        table.attach(box, 0, 1, 1, 2, AttachOptions.FILL, AttachOptions.FILL, 0, 0);
        table.attach(user_entry, 1, 2, 1, 2, AttachOptions.FILL, AttachOptions.FILL, 0, 0);
        
        var pass_label = new Label.with_mnemonic ("Password: ");
        pass_entry = new Entry();
        pass_entry.set_invisible_char('*');
        pass_entry.set_visibility(false);
        
        pass_label.mnemonic_widget = pass_entry;
        
        box = new HBox(false, 0);
        box.pack_end(pass_label, false, false, 5);
        table.attach(box, 0, 1, 2, 3, AttachOptions.FILL, AttachOptions.FILL, 0, 0);
        table.attach(pass_entry, 1, 2, 2, 3, AttachOptions.FILL, AttachOptions.FILL, 0, 0);

        // HACK! For some reason, without the two lines below the entry boxes above just
        // don't expand
        box = new HBox(false, 0);
        table.attach(box, 1, 2, 3, 4, AttachOptions.EXPAND, AttachOptions.EXPAND, 0, 0);
        
        advert = new CheckButton();
        advert.set_label("Show the lekhonee message in the posts");
        advert.set_active(true);
        
        this.vbox.pack_start (table, false, true, 0);
        this.vbox.pack_start (advert, false, true, 0);
        this.vbox.spacing = 10;
        
        //add_button (STOCK_CANCEL, ResponseType.CANCEL);
        this.apply_bttn = add_button (STOCK_OK, ResponseType.OK);
        this.response.connect (on_response);

    }
    
    
    private void on_response (Dialog source, int response_id) {
        switch (response_id) {
        case ResponseType.OK:
            server = server_entry.get_text();
            username = user_entry.get_text();
            if((server == "") | (username == "")) {
                return;
            }  
            
            ad = advert.get_active();
            keyf.set_string("details","server",server);
            keyf.set_string("details","username",username);
            //keyf.set_boolean("details","ad",ad);
            size_t length;
            Error e;
            string data = keyf.to_data(out length, out e);
            File fcon = File.new_for_path(filename);
            if(fcon.query_exists (null)){
                fcon.delete(null);
            }
            var file_stream = fcon.create (FileCreateFlags.REPLACE_DESTINATION, null);
            var data_stream = new DataOutputStream (file_stream);
            data_stream.put_string (data, null);

            hide_all();
            string password = pass_entry.get_text();
            
            config_done(server,username,password,ad);
            break;
        }
    }


}
