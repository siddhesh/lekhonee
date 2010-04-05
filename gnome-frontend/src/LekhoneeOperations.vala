using Xml;

public void xml_save_file(string filename, string title,string desc,string tags){
    Xml.Doc* doc;
    Xml.Node* root;
    string xmlstr;
    
    doc = new Xml.Doc ("1.0");

    root = new Xml.Node(null,"post");
    doc->set_root_element(root);
    root->new_text_child (null, "title", title);
    root->new_text_child (null, "description", desc);
    root->new_text_child (null, "tags", tags);
    //root->new_text_child (null, "categories", categories);
    
    doc->dump_memory (out xmlstr);
    try{
        File fcon = File.new_for_path(filename);
        if(fcon.query_exists (null)){
            fcon.delete(null);
        }
        var file_stream = fcon.create (FileCreateFlags.REPLACE_DESTINATION, null);
        var data_stream = new DataOutputStream (file_stream);
        data_stream.put_string (xmlstr, null);
    }catch(GLib.Error e){
        debug(e.message);
        return;
    }
}

public void xml_open_file(string path, out string title, out string desc, out string tags){
    Xml.Doc* doc = Parser.parse_file (path);
        if (doc == null) {
            stderr.printf ("File %s not found or permissions missing", path);
            return;
        }

        // Get the root node. notice the dereferencing operator -> instead of .
        Xml.Node* root = doc->get_root_element ();
        if (root == null) {
            // Free the document manually before returning
            delete doc;
            debug(@"The xml file '$path' is empty");
            return;
        }
        for (Xml.Node* iter = root->children; iter != null; iter = iter->next) {
            // Spaces between tags are also nodes, discard them
            if (iter->type != ElementType.ELEMENT_NODE) {
                continue;
            }

            // Get the node's name
            string node_name = iter->name;
            // Get the node's content with <tags> stripped
            string node_content = iter->get_content ();
            if(node_name == "title")
                title = node_content;
            if(node_name == "description")
                desc = node_content;
            if(node_name == "tags")
                tags = node_content;                

            debug(node_name);
            debug(node_content);

        }
        
        
        
    delete doc;
}
