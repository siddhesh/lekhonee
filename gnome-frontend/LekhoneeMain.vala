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
    
    
    public SourceBuffer blog_txt;
    public SourceView sourceview;
    
    public WebView editor;
    
    
    public Entry title_entry;
    public Entry tags_entry;
    public Button draft_bttn;
    public Button publish_bttn;

    public LekhoneeMain() {
        try {
        
        wp = new Wordpress();
        builder = new Builder ();
        builder.add_from_file ("new.ui");
        //builder.connect_signals (null);
        window = builder.get_object ("MainWindow") as Window;
        category_list = builder.get_object("category_list") as TreeView;
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
        category_list.insert_column_with_attributes (-1, "Categories", new CellRendererText (), "text", 0);
        category_list.set_model(liststore);
        var selection = category_list.get_selection();
        selection.set_mode(Gtk.SelectionMode.MULTIPLE);
        
        
        liststore2 = new ListStore(2, typeof(string),typeof(HashTable));
        entries_list = builder.get_object("entries_list") as TreeView;
        entries_list.insert_column_with_attributes (-1, "Post Title", new CellRendererText (), "text", 0);
        entries_list.set_model(liststore2);
        
        
        
        //Show/hide correct things
        window.show_all ();
        scw.hide_all();

        //For the upload file area in the UI
        vbox3 = builder.get_object("vbox3") as VBox;
        vbox3.hide_all();
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
    }
    
    public void store_config(string server,string user, string password){
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
        
        var new_menuitem = builder.get_object("imagemenuitem1") as ImageMenuItem;
        new_menuitem.activate.connect(on_new_cb);
        var quit_menuitem = builder.get_object("imagemenuitem5") as ImageMenuItem;
        quit_menuitem.activate.connect(quit);
        var p_menuitem = builder.get_object("preferences_menuitem") as ImageMenuItem;
        p_menuitem.activate.connect(show_config_dialog);
        
        
        
        
        //ALl menuitems under HTML Tags
        var blockquote_menuitem = builder.get_object("blockquote_menuitem") as MenuItem;
        blockquote_menuitem.activate.connect(on_blockquote_cb);
        var code_menuitem = builder.get_object("code_menuitem") as MenuItem;
        code_menuitem.activate.connect(on_code_cb);        
        var pre_menuitem = builder.get_object("pre_menuitem") as MenuItem;
        pre_menuitem.activate.connect(on_pre_cb);
        
        var last_entry_menuitem = builder.get_object("last_entry") as MenuItem;
        last_entry_menuitem.activate.connect(on_last_entry_cb);    

        
        
        var source_bttn = builder.get_object("source_bttn") as ToggleButton;
        source_bttn.toggled.connect(change_view);

        var link_ui_bttn = builder.get_object("link_ui_bttn") as ToolButton;
        link_ui_bttn.clicked.connect(link_bttn_cb);
        
        var image_ui_bttn = builder.get_object("image_ui_bttn") as ToolButton;
        image_ui_bttn.clicked.connect(image_bttn_cb);

        refresh_bttn.clicked.connect(get_categories);
        show_config_dialog(p_menuitem);
        //Errors
        wp.password_error.connect(show_error);
        
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
        }
        
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
            
            blog_txt.set_text(blog,(int)blog.size());
            scw2.hide_all();
            scw.show_all();
            source_flag = true;
            htmltags.set_sensitive(true);
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
            
        }
    }
    
    public void get_categories(Button b){
        liststore.clear();
        string[] result = wp.get_categories();
        
        foreach(string val in result){
            TreeIter iter = {};
            liststore.append(out iter);
            liststore.set(iter,0,val);
        }

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
        GenericDialog d = new GenericDialog("Insert URL of the image");
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
        GenericDialog d = new GenericDialog("Insert URL");
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
        HashTable<string,Value?> hash = wp.get_last_post();
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
        else
            editor.load_string(s_desc,"text/html","utf-8","preview");
            
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
        publish_bttn.set_label("Update");
        
        
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
            MessageDialog dm = new MessageDialog(window, Gtk.DialogFlags.MODAL, Gtk.MessageType.INFO, Gtk.ButtonsType.OK_CANCEL, "Are you sure to clear the currect post?");
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
        get_categories(refresh_bttn);
    }
    

    public bool navigation_requested(WebFrame p0, NetworkRequest p1, WebNavigationAction p2, WebPolicyDecision p3) {
        string uri = p1.get_uri();
        if (uri == "preview")
            return false;

        return true;
    }

    public void quit(Gtk.Object o){
        if(check_exit()){
            MessageDialog dm = new MessageDialog(window, Gtk.DialogFlags.MODAL, Gtk.MessageType.INFO, Gtk.ButtonsType.OK_CANCEL, "Are you sure to quit lekhonee-gnome without posting the current post?");
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




