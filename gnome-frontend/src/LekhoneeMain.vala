/* LekhoneeMain.vala
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
using WebKit;


public class LekhoneeMain: GLib.Object {
    
    public Wordpress wp;
    public Builder builder;
    public Window window;
    public TreeView category_list;
    public TreeView entries_list;
    public ListStore liststore;
    public ListStore liststore2;
    public ScrolledWindow scw;
    public ScrolledWindow scw2;
    public ScrolledWindow scw3;
    public VBox vbox3;
    public Button refresh_bttn;
    public bool source_flag;
    public bool edit_flag;
    public MenuItem htmltags;
    public ProgressBar progressbar;
    public Entry file_txt;
    public uint vid;
    public bool advert;
    
    
    public SourceBuffer blog_txt;
    public SourceView sourceview;
    
    public WebView editor;
    
    
    public Entry title_entry;
    public Entry tags_entry;
    public Button draft_bttn;
    public Button publish_bttn;
    public CheckButton spell_box;
    public Value entry;
    
    public Spell spell;

    public LekhoneeMain() {
        try {
        
        wp = new Wordpress();
        wp.password_error.connect(show_error);
        builder = new Builder ();
        builder.add_from_file (Config.PKGDATADIR + "/new.ui");
        //builder.connect_signals (null);
        window = builder.get_object ("MainWindow") as Window;
        category_list = builder.get_object("category_list") as TreeView;
        progressbar = builder.get_object("progressbar") as ProgressBar;
        title_entry = builder.get_object("titleTxt") as Entry;
        tags_entry = builder.get_object("tags_entry") as Entry;
        draft_bttn = builder.get_object("draft_bttn") as Button;
        publish_bttn = builder.get_object("publish_bttn") as Button;
        edit_flag = false;
        
        
        //For the sourceview
        SourceLanguageManager langm = new SourceLanguageManager();
        SourceLanguage lang = langm.get_language("html");
        scw = builder.get_object("scw") as ScrolledWindow;
        blog_txt = new Gtk.SourceBuffer.with_language(lang);
        sourceview =  new SourceView.with_buffer(blog_txt);
        sourceview.wrap_mode = Gtk.WrapMode.WORD;
        scw.add(sourceview);
        
        //For the Webkit editor
        editor = new WebView();
        editor.set_editable(true);
        editor.load_string("","text/html","utf-8","preview");
        editor.navigation_policy_decision_requested.connect(navigation_requested);


        scw2 = builder.get_object("scw2") as ScrolledWindow;
        scw2.add(editor);
        scw2.vscrollbar.set_visible(true);
        
        htmltags = builder.get_object("menuitem3") as MenuItem;
        htmltags.set_sensitive(false);
        
        
        liststore = new ListStore(1, typeof(string));
        category_list = builder.get_object("category_list") as TreeView;
        category_list.insert_column_with_attributes (-1, _("Categories"), new CellRendererText (), "text", 0);
        category_list.set_model(liststore);
        var selection = category_list.get_selection();
        selection.set_mode(Gtk.SelectionMode.MULTIPLE);
        
        
        liststore2 = new ListStore(2, typeof(string),typeof(HashTable));
        entries_list = builder.get_object("entries_list") as TreeView;
        entries_list.insert_column_with_attributes (-1, _("Post Title"), new CellRendererText (), "text", 0);
        entries_list.set_model(liststore2);
        var selection2 = entries_list.get_selection();
        selection2.set_mode(Gtk.SelectionMode.SINGLE);
        entry = Value(typeof(HashTable));
        
        
        //Show/hide correct things
        window.show_all ();
        scw.hide_all();
        progressbar.hide_all();

        //For the upload file area in the UI
        vbox3 = builder.get_object("vbox3") as VBox;
        vbox3.hide_all();
        file_txt = builder.get_object("file_txt") as Entry;
        
        
        //For the entries_list treeview
        scw3 = builder.get_object("scw3") as ScrolledWindow;
        scw3.hide_all();
        
        
        window.resize(700,400);        
        source_flag = false;
        window.delete_event.connect(on_delete_event);
        
        refresh_bttn = builder.get_object("refresh_bttn") as Button;
        create_connections();
        
        
        editor.realize();
        editor.grab_focus();

        }
        catch (Error e) {
            stderr.printf ("Could not load UI: %s\n", e.message);
        }
    }

    public void show_config_dialog(MenuItem i){
        var dm = new ConfigDialog();
        dm.config_done.connect(store_config);
        dm.show_all();
        dm.run();
        dm.destroy();
    }
    
    public void store_config(string server,string user, string password,bool ad){
        advert = ad;
        wp.set_details(user,password,server);
        get_categories(refresh_bttn);
    }
    
    public void show_dialog(MenuItem w){
        var dialog = new AboutDialog();
        dialog.set_name("lekhonee-gnome");
        dialog.set_copyright("(c) 2009-2010 Kushal Das");
        dialog.set_website("http://fedorahosted.org/lekhonee");
        dialog.set_version("0.9");
        dialog.set_authors({"Kushal Das kushal@fedoraproject.org",null});
        dialog.set_program_name("lekhonee-gnome");
        dialog.run();
        dialog.destroy();
    }

    public void create_connections(){
        var about_activity = builder.get_object("imagemenuitem10") as ImageMenuItem;
        about_activity.activate.connect(show_dialog);
        var bold = builder.get_object("bold") as ToolButton;
        var italic = builder.get_object("italic") as ToolButton;
        var underline = builder.get_object("underline") as ToolButton;
        var insertunorderedlist = builder.get_object("insertunorderedlist") as ToolButton;
        bold.clicked.connect(on_action);
        italic.clicked.connect(on_action);
        underline.clicked.connect(on_action);
        insertunorderedlist.clicked.connect(on_action);

        var p_menuitem = builder.get_object("preferences_menuitem") as ImageMenuItem;
        p_menuitem.activate.connect(show_config_dialog);
        
        //File menu
        var save_menuitem = builder.get_object("save_menuitem") as ImageMenuItem;
        save_menuitem.activate.connect(save_file_cb);
        var open_menuitem = builder.get_object("open_menuitem") as ImageMenuItem;
        open_menuitem.activate.connect(open_file_cb);
        var new_menuitem = builder.get_object("imagemenuitem1") as ImageMenuItem;
        new_menuitem.activate.connect(on_new_cb);
        var quit_menuitem = builder.get_object("imagemenuitem5") as ImageMenuItem;
        quit_menuitem.activate.connect(quit);        
        
        //ALl menuitems under HTML Tags
        var blockquote_menuitem = builder.get_object("blockquote_menuitem") as MenuItem;
        blockquote_menuitem.activate.connect(on_blockquote_cb);
        var code_menuitem = builder.get_object("code_menuitem") as MenuItem;
        code_menuitem.activate.connect(on_code_cb);        
        var pre_menuitem = builder.get_object("pre_menuitem") as MenuItem;
        pre_menuitem.activate.connect(on_pre_cb);
        
        var last_entry_menuitem = builder.get_object("last_entry") as MenuItem;
        last_entry_menuitem.activate.connect(on_last_entry_cb);    
        var upload_menuitem = builder.get_object("upload_menuitem") as MenuItem;
        upload_menuitem.activate.connect(on_upload_cb); 
        
        //Connected all upload file stuff
        var cancel_bttn = builder.get_object("file_cancel_bttn") as Button;
        cancel_bttn.clicked.connect(on_cancel_cb);
        var file_select_bttn = builder.get_object("file_select_bttn") as Button;
        file_select_bttn.clicked.connect(on_select_cb);
        var file_upload_bttn = builder.get_object("file_upload_bttn") as Button;
        file_upload_bttn.clicked.connect(on_uploadfile_cb);

        var publish_bttn = builder.get_object("publish_bttn") as Button;
        publish_bttn.clicked.connect(on_publish_cb);
        
        var draft_bttn = builder.get_object("draft_bttn") as Button;
        draft_bttn.clicked.connect(on_draft_cb);
        
        var old_posts_menuitem = builder.get_object("old_posts_menuitem") as MenuItem;
        old_posts_menuitem.activate.connect(on_old_posts_menuitem_cb);
        //Get if user is pressing Escape in the old posts view
        entries_list.key_press_event.connect(on_oldposts_key_cb);
        entries_list.button_press_event.connect(on_oldposts_button_cb);
        
        var source_bttn = builder.get_object("source_bttn") as ToggleButton;
        source_bttn.toggled.connect(change_view);

        var link_ui_bttn = builder.get_object("link_ui_bttn") as ToolButton;
        link_ui_bttn.clicked.connect(link_bttn_cb);
        
        var image_ui_bttn = builder.get_object("image_ui_bttn") as ToolButton;
        image_ui_bttn.clicked.connect(image_bttn_cb);

        //For spell check
        spell_box = builder.get_object("spell_box") as CheckButton;
        spell_box.toggled.connect(on_spell_cb);
        spell_box.set_sensitive(false);

        refresh_bttn.clicked.connect(get_categories);
        show_config_dialog(p_menuitem);
        //Errors

        wp.get_old_posts.connect(populate_posts);
        
    }
    
    public void on_spell_cb(ToggleButton b){
        if(b.get_active()){
            spell = new Spell.attach(sourceview,null);
            spell.recheck_all();
        }else{
            spell.detach();
        }

    }
    
    public void show_error(string message){
        var dm = new MessageDialog(window, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, message);
        dm.run();
        dm.destroy();
    }

    public void on_action(ToolButton button){
        string name = button.get_name();
        if (!source_flag){
            editor.execute_script(@"document.execCommand('$name', false, false);");
        }
        else {
            if(name == "bold")
                bold_bttn_cb();
            else if(name == "italic")
                italic_bttn_cb();
            else if(name == "underline")
                underline_bttn_cb();
            else if(name == "insertunorderedlist")
                unorderedlist_cb();
        }
        
    }
    
    public void unorderedlist_cb(){
        TextIter start={};
        TextIter end={};
        blog_txt.get_selection_bounds(out start, out end);
        string text = blog_txt.get_text(start,end,false);
        blog_txt.delete(start,end);
        string result = @"<ul><li>$text</li></ul>";
        blog_txt.insert_at_cursor(result,(int)result.size());
    }

    public string get_source(){
        editor.execute_script("document.title=document.documentElement.innerHTML;");
        string mes = editor.get_main_frame().get_title();
        string[] odds = mes.split("<body>");
        return odds[1];
        
    }
    
    public void change_view(ToggleButton button){
        if (button.get_active()) {
            string blog = get_source()[0:-7];
            blog = blog.replace("<br>","\n");
            blog_txt.set_text(blog,(int)blog.size());
            scw2.hide_all();
            scw.show_all();
            source_flag = true;
            htmltags.set_sensitive(true);
            spell_box.set_sensitive(true);
        }
        else{
            scw.hide_all();
            scw2.show_all();
            TextIter start,end;
            blog_txt.get_bounds(out start, out end);
            string text = blog_txt.get_text(start, end,false);
            text = text.replace("\n","<br>");
            string html = @"<html><title></title><body>$text</body</html>";
            editor.load_string(html,"text/html","utf-8","preview");
            source_flag = false;
            htmltags.set_sensitive(false);
            spell_box.set_sensitive(false);
        }
    }
    
    public void get_categories(Button b){
        liststore.clear();
        progressbar.show_all();
        vid = Timeout.add(100,update_bar,Priority.HIGH);
        progressbar.set_text(_("Fetching categories from server"));
        
        string[] result = wp.get_categories();
        
        foreach(string val in result){
            TreeIter iter = {};
            liststore.append(out iter);
            liststore.set(iter,0,val);
        }
        
        Source.remove(vid);
        progressbar.set_fraction(0.0);
        progressbar.set_text("");
        progressbar.hide_all();
        
    }
    
    public void bold_bttn_cb(){
        TextIter start={};
        TextIter end={};
        blog_txt.get_selection_bounds(out start, out end);
        string text = blog_txt.get_text(start,end,false);
        blog_txt.delete(start,end);
        string result = @"<strong>$text</strong>";
        blog_txt.insert_at_cursor(result,(int)result.size());
    }
    
    public void italic_bttn_cb(){
        TextIter start={};
        TextIter end={};
        blog_txt.get_selection_bounds(out start, out end);
        string text = blog_txt.get_text(start,end,false);
        blog_txt.delete(start,end);
        string result = @"<i>$text</i>";
        blog_txt.insert_at_cursor(result,(int)result.size());
    }
    
    public void underline_bttn_cb(){
        TextIter start={};
        TextIter end={};
        blog_txt.get_selection_bounds(out start, out end);
        string text = blog_txt.get_text(start,end,false);
        blog_txt.delete(start,end);
        string result = @"<u>$text</u>";
        blog_txt.insert_at_cursor(result,(int)result.size());
    }
    
    public void image_bttn_cb(ToolButton b){
        GenericDialog d = new GenericDialog(_("Insert URL of the image"));
        d.show_all();
        d.send_link.connect(insert_image);
    }
    
    public void insert_image(string mes){
        if (source_flag){
            TextIter start={};
            TextIter end={};
            blog_txt.get_selection_bounds(out start, out end);
            string text = blog_txt.get_text(start,end,false);
            blog_txt.delete(start,end);
            string result = @"<image src=\"$mes\">$text";
            blog_txt.insert_at_cursor(result,(int)result.size());
        }
        else{
            string result = @"document.execCommand('insertImage', null, '$mes');";
            editor.execute_script(result);  
        }
    }

    public void link_bttn_cb(ToolButton b){
        GenericDialog d = new GenericDialog(_("Insert URL"));
        d.show_all();
        d.send_link.connect(insert_link);
    }
    
    public void insert_link(string mes){
        if (source_flag){
            TextIter start={};
            TextIter end={};
            blog_txt.get_selection_bounds(out start, out end);
            string text = blog_txt.get_text(start,end,false);
            blog_txt.delete(start,end);
            string result = @"<a href=\"$mes\">$text</a>";
            blog_txt.insert_at_cursor(result,(int)result.size());
        }
        else{
            string result = @"document.execCommand('createLink', true, '$mes');";
            editor.execute_script(result);  
        }
    }
    
    public void on_blockquote_cb(MenuItem i){
        if (source_flag){
            TextIter start={};
            TextIter end={};
            blog_txt.get_selection_bounds(out start, out end);
            string text = blog_txt.get_text(start,end,false);
            blog_txt.delete(start,end);
            string result = @"<blockquote>$text</blockquote>";
            blog_txt.insert_at_cursor(result,(int)result.size());
        }

    }
    
    public void on_code_cb(MenuItem i){
        if (source_flag){
            TextIter start={};
            TextIter end={};
            blog_txt.get_selection_bounds(out start, out end);
            string text = blog_txt.get_text(start,end,false);
            blog_txt.delete(start,end);
            string result = @"<code>$text</code>";
            blog_txt.insert_at_cursor(result,(int)result.size());
        }
    }
    
    public void on_pre_cb(MenuItem i){
        if (source_flag){
            TextIter start={};
            TextIter end={};
            blog_txt.get_selection_bounds(out start, out end);
            string text = blog_txt.get_text(start,end,false);
            blog_txt.delete(start,end);
            string result = @"<pre>$text</pre>";
            blog_txt.insert_at_cursor(result,(int)result.size());
        }
    }
    
    public void on_last_entry_cb(MenuItem i){
    
        progressbar.show_all();
        vid = Timeout.add(100,update_bar,Priority.HIGH);
        progressbar.set_text("Fetching the last post from server");
        
        entry = wp.get_last_post();
        
        Source.remove(vid);
        progressbar.set_fraction(0.0);
        progressbar.set_text("");
        progressbar.hide_all();
        load_post_details();
    }
    
    public void load_post_details(){
        HashTable<string,Value?> hash = (HashTable<string,Value?>)entry; 
        if ((int)hash.size() == 0)
            return;
            
        var title = hash.lookup("title");
        string s_title = title.get_string();
        title_entry.set_text(s_title);
        
        var desc = hash.lookup("description");
        string s_desc = desc.get_string();
        
        if(source_flag){
            blog_txt.set_text(s_desc,(int)s_desc.size());;        
        }
        else {
            s_desc = s_desc.replace("\n","<br>");
            string html = @"<html><title></title><body>$s_desc</body</html>";
            editor.load_string(html,"text/html","utf-8","preview");
        }     
        var tags = hash.lookup("mt_keywords");
        string s_tags = tags.get_string();
        tags_entry.set_text(s_tags);
        
        var ts = category_list.get_selection();
        unowned ValueArray categories = (ValueArray)hash.lookup("categories");
        foreach(var cate in categories){
            for(int ii=0;ii<liststore.length;ii++){
                TreeIter iter = {};
                TreePath path = new TreePath.from_string(ii.to_string());
                liststore.get_iter(out iter,path);
                Value V = Value(typeof(string));
                liststore.get_value(iter,0, out V);
                if(cate.get_string() == V.get_string())
                    ts.select_iter(iter);
            }
        }
        edit_flag = true;
        draft_bttn.set_sensitive(false);
        publish_bttn.set_label(_("Update"));
        
        
    }

    public void on_old_posts_menuitem_cb(MenuItem i){
        //Gets the details from the server
        liststore2.clear();
        progressbar.show_all();
        vid = Timeout.add(200,update_bar,Priority.HIGH);
        progressbar.set_text(_("Fetching posts from server"));
        bool ret = wp.get_posts();
        if(ret){
            scw3.show_all();
            entries_list.grab_focus();
        }
        Source.remove(vid);
        progressbar.set_fraction(0.0);
        progressbar.hide_all();
        
    }
    
    public bool update_bar(){
        progressbar.pulse();
        return true;
    }
    
    public bool on_oldposts_key_cb(Gdk.EventKey event){
        if (event.keyval == 65307)
            scw3.hide_all();
        
        return true;
    
    }
    
    public bool on_oldposts_button_cb(Gdk.EventButton event){
        //Load the selected entry
        if (event.type == Gdk.EventType.2BUTTON_PRESS){
            TreeSelection sect = entries_list.get_selection();
            TreeModel model;
            TreeIter iter;
            sect.get_selected(out model, out iter);
            
            model.get_value(iter,1,out entry);
            load_post_details();
            scw3.hide_all();
        }
        return false;
    
    }
    
    public void populate_posts(ValueArray values){
        // Connected with the server and gets the details from there
        for(int i=0;i<values.n_values;i++){
            var hash = (HashTable<string,Value?>)values.get_nth(i);
            var val = hash.lookup("title");
            TreeIter iter = {};
            liststore2.append(out iter);
            liststore2.set(iter,0,val.get_string());
            liststore2.set(iter,1,hash);
        }
        Source.remove(vid);
        progressbar.set_fraction(0.0);
        progressbar.set_text("");
        progressbar.hide_all();
    }
    
    public bool check_exit(){
        string text;
        if(source_flag){
            TextIter start,end;
            blog_txt.get_bounds(out start, out end);
            text = blog_txt.get_text(start, end,false);
        }else
            text = get_source()[0:-7];
            
        if(text.length == 0)
            return false;
        else
            return true;

    }

    public void on_new_cb(MenuItem i){
        if(check_exit()){
            MessageDialog dm = new MessageDialog(window, Gtk.DialogFlags.MODAL, Gtk.MessageType.INFO, Gtk.ButtonsType.OK_CANCEL, _("Are you sure to clear the currect post?"));
            dm.response.connect (on_newcb_response);
            dm.run();
            dm.destroy();
        }
    }

    public void on_newcb_response(Dialog source, int response_id){
        switch (response_id) {
        case ResponseType.OK:
            //clear_it();
            clear_it();
            break;
        }
    }

    public void clear_it(){
        TextIter start,end;
        blog_txt.get_bounds(out start, out end);
        blog_txt.set_text("",0);
        title_entry.set_text("");
        tags_entry.set_text("");
        editor.load_string("","text/html","utf-8","preview");
        if (edit_flag){
            edit_flag = true;
            publish_bttn.set_label("Publish");
            draft_bttn.set_sensitive(true);
        }
        //Not refreshing the categories, if required user will click refresh
        //get_categories(refresh_bttn);
    }
    
    public void on_upload_cb(MenuItem i){
        vbox3.show_all();
    }

    public void on_cancel_cb(Button b){
        vbox3.hide_all();
    }
    
    public void on_select_cb(Button b){
        FileChooserDialog chooser = new Gtk.FileChooserDialog(("Select File"),
        window, Gtk.FileChooserAction.OPEN, Gtk.STOCK_CANCEL, 
        Gtk.ResponseType.CANCEL, Gtk.STOCK_OPEN, Gtk.ResponseType.ACCEPT, null);
        
        if (chooser.run() == Gtk.ResponseType.ACCEPT) {
            string name = chooser.get_filename();
            file_txt.set_text(name);
        }
        chooser.destroy();
    }
    
    public void on_uploadfile_cb(Button b){
        File file = File.new_for_path(file_txt.get_text());
        if (!file.query_exists (null)) 
            return;
        string raw_data;
        size_t l;
        try{
            FileUtils.get_contents(file_txt.get_text(),out raw_data, out l);
        }catch(FileError e){
            debug(e.message);
            return;
        }
        //string datum = Base64.encode((uchar[])raw_data.to_utf8());
        bool t;
        string content_type = g_content_type_guess(file_txt.get_text(),(uchar[])raw_data.to_utf8(),out t);
        HashTable<string,Value?> hash = new HashTable<string, Value?>.full (str_hash, str_equal, g_free, g_free);
        Value type = content_type;
        Value name = GLib.Filename.display_basename(file_txt.get_text());
        
        string output;
        string error;
        int exit_status;
        try{
            Process.spawn_command_line_sync("base64" + " " + file_txt.get_text(), out output, out error, out exit_status);
        }catch(SpawnError e){
            debug(e.message);
            vbox3.hide_all();
            return;
        }
        
        hash.insert("name",name);
        hash.insert("type",type);
        hash.insert("bits",output);
        //debug(content_type);
        
        progressbar.show_all();
        vid = Timeout.add(200,update_bar,Priority.HIGH);
        progressbar.set_text(_("Uploading file to the server"));
        string mes = wp.upload_file(hash);
        if (source_flag){
            TextIter start={};
            TextIter end={};
            blog_txt.get_selection_bounds(out start, out end);
            string text = blog_txt.get_text(start,end,false);
            blog_txt.delete(start,end);
            string result = @"<a href=\"$mes\">$text</a>";
            blog_txt.insert_at_cursor(result,(int)result.size());
        }
        else{
            string result = @"document.execCommand('createLink', true, '$mes');";
            editor.execute_script(result);  
        }
        vbox3.hide_all();
        Source.remove(vid);
        progressbar.set_fraction(0.0);
        progressbar.set_text("");
        progressbar.hide_all();
        
        
    }
    
    public void on_publish_cb(Button b){
        message_post(true);
        return;
    }
    
    public void on_draft_cb(Button b){
        message_post(false);
        return;
    }
    
    public void message_post(bool publish){
        Value desc;
        string inter_desc = "";
        if(source_flag){
            TextIter start,end;
            blog_txt.get_bounds(out start, out end);
            inter_desc = (string)blog_txt.get_text(start, end,false);
        }else{
            inter_desc = (string)get_source()[0:-7];
        }
        
        if(!edit_flag){
            if(advert)
                inter_desc = inter_desc + "<br>The post is brought to you by <a href=\"http://fedorahosted.org/lekhonee\">lekhonee-gnome</a> v0.9";
        }
        desc = inter_desc;
        
        Value title = (string)title_entry.get_text();
        HashTable<string,Value?> hash = new HashTable<string, Value?>.full (str_hash, str_equal, g_free, g_free);
        string[] tags = tags_entry.get_text().split(",");
        ValueArray mtags = new ValueArray(1);
        foreach(string x in tags){
            mtags.append(x.strip());
        }
        ValueArray cats = new ValueArray(1);
        TreeSelection sect = category_list.get_selection();
        
        TreeModel model;
        TreeIter iter;
        
        var slist = sect.get_selected_rows(out model);
        foreach(var sec in slist){
            model.get_iter(out iter, sec);
            Value v = Value(typeof(string));
            liststore.get_value(iter,0, out v);
            cats.append(v.get_string());
        
        }
        var comment_box = builder.get_object("comment_box") as CheckButton;
        Value comments = comment_box.get_active();
        hash.insert("title",title);
        hash.insert("description",desc);
        hash.insert("mt_keywords",mtags);
        hash.insert("categories",cats);
        hash.insert("mt_allow_comments",comments);
        
        progressbar.show_all();
        vid = Timeout.add(200,update_bar,Priority.HIGH);
        progressbar.set_text(_("posting to the server"));
        string pid;
        if (edit_flag){
            string postid;
            HashTable<string,Value?> oldhash = (HashTable<string,Value?>)entry;
            Value val = oldhash.lookup("postid");
            postid= val.get_string();
            pid = wp.update(postid,hash,publish);
        }else
            pid = wp.post(hash,publish);
        if(pid != "None"){
            MessageDialog dm = new MessageDialog(window, Gtk.DialogFlags.MODAL, Gtk.MessageType.INFO, Gtk.ButtonsType.OK,  pid);
            dm.run();
            dm.destroy();
        }
        Source.remove(vid);
        progressbar.set_text("");
        progressbar.set_fraction(0.0);
        progressbar.hide_all();
        clear_it();
        edit_flag = false;
    }
    
    public void open_file_cb(MenuItem i) {
        string title = "";
        string desc = "";
        string tags = "";
        
        Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog(("Open Post"),
        window, Gtk.FileChooserAction.OPEN, Gtk.STOCK_CANCEL, 
        Gtk.ResponseType.CANCEL, Gtk.STOCK_OPEN, Gtk.ResponseType.ACCEPT, null);
        chooser.set_do_overwrite_confirmation(true);
        chooser.set_current_folder(Environment.get_home_dir());
        var filter = new FileFilter();
        filter.set_name("Lekhonee files");
        filter.add_pattern("*.lekhonee");
        chooser.add_filter(filter);
        
        if (chooser.run() == Gtk.ResponseType.ACCEPT) { 
            string filename = chooser.get_filename();
            xml_open_file(filename, out title, out desc, out tags);
        }
        title_entry.set_text(title);
        tags_entry.set_text(tags);
        editor.load_string(desc,"text/html","utf-8","preview");
        chooser.destroy();
    }
    
    public void save_file_cb(MenuItem i){
         Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog(("Save Post"),
        window, Gtk.FileChooserAction.SAVE, Gtk.STOCK_CANCEL, 
        Gtk.ResponseType.CANCEL, Gtk.STOCK_SAVE, Gtk.ResponseType.ACCEPT, null);
        chooser.set_do_overwrite_confirmation(true);
        chooser.set_current_folder(Environment.get_home_dir());
        var filter = new FileFilter();
        filter.set_name("Lekhonee files");
        filter.add_pattern("*.lekhonee");
        chooser.add_filter(filter);
        

        if (chooser.run() == Gtk.ResponseType.ACCEPT) {      
        
            string title = title_entry.get_text();
            string desc;
            if(source_flag){
                TextIter start,end;
                blog_txt.get_bounds(out start, out end);
                desc = blog_txt.get_text(start, end,false);
            }else
                desc = get_source()[0:-7];
            
            string tags = tags_entry.get_text();
            string filename;
            string? oldname; 
            oldname = chooser.get_filename();
            if(oldname != null){
                filename = (!) oldname;
                if(!filename.has_suffix(".lekhonee"))
                    filename = filename + ".lekhonee";
                
            }else{
                chooser.destroy();
                return;
            }

            xml_save_file(filename,title,desc,tags);
        }
        chooser.destroy();
    }
    
    
    public bool navigation_requested(WebFrame p0, NetworkRequest p1, WebNavigationAction p2, WebPolicyDecision p3) {
        string uri = p1.get_uri();
        if (uri == "preview")
            return false;

        return true;
    }

    public void quit(Gtk.Object o){
        if(check_exit()){
            MessageDialog dm = new MessageDialog(window, Gtk.DialogFlags.MODAL, Gtk.MessageType.INFO, Gtk.ButtonsType.OK_CANCEL, _("Are you sure to quit lekhonee-gnome without posting the current post?"));
            dm.response.connect (on_quit_response);
            dm.run();
            dm.destroy();
        }else
            Gtk.main_quit();
    }

    public void on_quit_response(Dialog source, int response_id){
        switch (response_id) {
        case ResponseType.OK:
            Gtk.main_quit();
            break;
        }
    }

    public bool on_delete_event (Gtk.Widget w, Gdk.Event e){
        quit(refresh_bttn);
        return true;
    }

    public static int main (string[] args) {

        Gtk.init (ref args);


        LekhoneeMain lh = new LekhoneeMain();


        Gtk.main ();


        return 0;
    }

}




