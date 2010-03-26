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
    public ListStore liststore;
    public ScrolledWindow scw;
    public ScrolledWindow scw2;
    public ScrolledWindow scw3;
    public HButtonBox hbuttonbox1;
    public Toolbar toolbar;
    public VBox vbox3;
    public Button refresh_bttn;
    public bool source_flag;
    
    public SourceBuffer blog_txt;
    public SourceView sourceview;
    
    public WebView editor;

    public LekhoneeMain() {
        try {
        
        wp = new Wordpress();
        wp.set_details("kushaldas","mamaD1");
        builder = new Builder ();
        builder.add_from_file ("new.ui");
        //builder.connect_signals (null);
        window = builder.get_object ("MainWindow") as Window;
        category_list = builder.get_object("category_list") as TreeView;
        
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
        editor.load_string("Vala rocks!","text/html","utf-8","preview");
        editor.navigation_policy_decision_requested.connect(navigation_requested);

        scw2 = builder.get_object("scw2") as ScrolledWindow;
        scw2.add(editor);
        
        
        liststore = new ListStore(1, typeof(string));
        category_list = builder.get_object("category_list") as TreeView;
        category_list.insert_column_with_attributes (-1, "Categories", new CellRendererText (), "text", 0);
        category_list.set_model(liststore);
        var selection = category_list.get_selection();
        selection.set_mode(Gtk.SelectionMode.MULTIPLE);
        
        
        //Show/hide correct things
        window.show_all ();
        scw.hide_all();
        toolbar = builder.get_object("toolbar") as Toolbar;
        hbuttonbox1 = builder.get_object("hbuttonbox1") as HButtonBox;
        hbuttonbox1.hide_all();
        //For the upload file area in the UI
        vbox3 = builder.get_object("vbox3") as VBox;
        vbox3.hide_all();
        //For the entries_list treeview
        scw3 = builder.get_object("scw3") as ScrolledWindow;
        scw3.hide_all();
        
        
        
        source_flag = false;
        window.destroy.connect (Gtk.main_quit);
        
        refresh_bttn = builder.get_object("refresh_bttn") as Button;
        create_connections();
        get_categories(refresh_bttn);
        
        }
        catch (Error e) {
            stderr.printf ("Could not load UI: %s\n", e.message);
        }
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
        
        var blockquote_menuitem = builder.get_object("blockquote_menuitem") as MenuItem;
        blockquote_menuitem.activate.connect(on_blockquote_cb);
        
        var source_bttn = builder.get_object("source_bttn") as ToggleButton;
        source_bttn.toggled.connect(change_view);
        
        var bold_bttn = builder.get_object("bold_bttn") as Button;
        bold_bttn.clicked.connect(bold_bttn_cb);
        
        var italic_bttn = builder.get_object("italic_bttn") as Button;
        italic_bttn.clicked.connect(italic_bttn_cb);

        var underline_bttn = builder.get_object("underline_bttn") as Button;
        underline_bttn.clicked.connect(underline_bttn_cb);        

        var link_bttn = builder.get_object("link_bttn") as Button;
        link_bttn.clicked.connect(link_bttn_cb);


        var link_ui_bttn = builder.get_object("link_ui_bttn") as ToolButton;
        link_ui_bttn.clicked.connect(link_bttn_cb);

        refresh_bttn.clicked.connect(get_categories);
    }

    public void on_action(ToolButton button){
        string name = button.get_name();
        editor.execute_script(@"document.execCommand('$name', false, false);");
        
    }

    public string get_source(){
        editor.execute_script("document.title=document.documentElement.innerHTML;");
        string message =  editor.get_main_frame().get_title();
        
        string[] odds = message.split("<body>");
        debug(odds[1]);
        return odds[1];
    }
    
    public void change_view(ToggleButton button){
        if (button.get_active()) {
            string blog = get_source()[0:-7];
            
            blog_txt.set_text(blog,(int)blog.size());
            scw2.hide_all();
            scw.show_all();
            hbuttonbox1.show_all();
            toolbar.hide_all();
            source_flag = true;
        }
        else{
            scw.hide_all();
            scw2.show_all();
            toolbar.show_all();
            hbuttonbox1.hide_all();
            TextIter start,end;
            blog_txt.get_bounds(out start, out end);
            string text = blog_txt.get_text(start, end,false);
            debug("TEXT: " + text);
            text = text.replace("\n","<br>");
            string html = @"<html><title></title><body>$text</body</html>";
            editor.load_string(html,"text/html","utf-8","preview");
            source_flag = false;
            
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
    
    public void bold_bttn_cb(Button b){
        TextIter start={};
        TextIter end={};
        blog_txt.get_selection_bounds(out start, out end);
        string text = blog_txt.get_text(start,end,false);
        blog_txt.delete(start,end);
        string result = @"<strong>$text</strong>";
        blog_txt.insert_at_cursor(result,(int)result.size());
    }
    
    public void italic_bttn_cb(Button b){
        TextIter start={};
        TextIter end={};
        blog_txt.get_selection_bounds(out start, out end);
        string text = blog_txt.get_text(start,end,false);
        blog_txt.delete(start,end);
        string result = @"<i>$text</i>";
        blog_txt.insert_at_cursor(result,(int)result.size());
    }
    
    public void underline_bttn_cb(Button b){
        TextIter start={};
        TextIter end={};
        blog_txt.get_selection_bounds(out start, out end);
        string text = blog_txt.get_text(start,end,false);
        blog_txt.delete(start,end);
        string result = @"<u>$text</u>";
        blog_txt.insert_at_cursor(result,(int)result.size());
    }
    
    public void link_bttn_cb(Gtk.Object b){
        GenericDialog d = new GenericDialog("Link");
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
        else{
            string result = @"document.execCommand('blockquote', false, false);";
            editor.execute_script(result);  
        }
        
    }
    
    public bool navigation_requested(WebFrame p0, NetworkRequest p1, WebNavigationAction p2, WebPolicyDecision p3) {
        //empty
        return true;
    }

    public static int main (string[] args) {     
        
        
        Gtk.init (ref args);

 
        LekhoneeMain lh = new LekhoneeMain();

            
        Gtk.main ();
             

        return 0;
    }

}




