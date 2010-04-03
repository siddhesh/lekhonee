using Soup;

public class Wordpress: Object {
    public string username {get;set;}
    public string password;
    public string server;
    public signal void password_error(string mesaage);
    public signal void get_old_posts(ValueArray v);

    public void set_details(string name, string pass, string serv) {
        this.username = name;
        this.password = pass;
        this.server = serv;
    }

    public string post(HashTable content, bool publish) {
        var message = xmlrpc_request_new(server,"metaWeblog.newPost",typeof(int),1,typeof(string),this.username,typeof(string),this.password,typeof(HashTable),content, typeof(bool), publish);
        var session = new SessionSync();
        session.send_message(message);
        
        string data =message.response_body.flatten().data;
        return data;
        
    }
    
    public string upload_file(HashTable data) {
        var message = xmlrpc_request_new(server,"wp.uploadFile",typeof(int),1,typeof(string),this.username,typeof(string),this.password,typeof(HashTable),data);
        var session = new SessionAsync();
        session.send_message(message);
        
        string returndata =message.response_body.flatten().data;
        Value v = Value(typeof(HashTable));
        try{
            xmlrpc_parse_method_response(returndata, -1,v);
        }catch (Error e){ 
            password_error(e.message);
            return "";
        }
        HashTable<string, Value?> hash = (HashTable)v;
        var x = hash.lookup("url");
        
        return (string)x;
    }
    
    
    public void add_category(string category) {
        var message = xmlrpc_request_new(server,"wp.newCategory",typeof(int),1,typeof(string),this.username,typeof(string),this.password,typeof(string),category);
        var session = new SessionSync();
        session.send_message(message);

    }
    
    public HashTable get_last_post(){
        var message = xmlrpc_request_new(server,"metaWeblog.getRecentPosts",typeof(int),1,typeof(string),this.username,typeof(string),this.password,typeof(int),1);
        var session = new SessionAsync();
        var return_code = session.send_message(message);
        if (return_code == 2){
            password_error("Please check your network");
            return new HashTable<string, string>.full (str_hash, str_equal, g_free, g_free);
        }
        
        string data =message.response_body.flatten().data;
        //stdout.printf("%d\n",(int)data.length);
        unowned ValueArray v3;
        Value v = Value(typeof(ValueArray));
        try{
            xmlrpc_parse_method_response(data, -1,v);
        }catch (Error e){ 
            password_error(e.message);
            return new HashTable<string, string>.full (str_hash, str_equal, g_free, g_free);
        }
        v3 = (ValueArray)v;
        var hash = (HashTable<string,Value?>)v3.get_nth(0);
        return hash;

    }

    public void get_posts(){
        var message = xmlrpc_request_new(server,"metaWeblog.getRecentPosts",typeof(int),1,typeof(string),this.username,typeof(string),this.password,typeof(int),10);
        var session = new SessionAsync();
        var return_code = session.send_message(message);
        
        if (return_code == 2){
            password_error("Please check your network");
            
        }
        
        string data =message.response_body.flatten().data;
        //stdout.printf("%d\n",(int)data.length);
        unowned ValueArray v3;
        Value v = Value(typeof(ValueArray));
        try{
            xmlrpc_parse_method_response(data, -1,v);
        }catch (Error e){ 
            password_error(e.message);
            return;
;
        }
        v3 = (ValueArray)v;
        get_old_posts(v3);
        //return v3;
        //var hash = (HashTable<string,Value?>)v3.get_nth(0);

    }

    public string[] get_categories(){
        var message = xmlrpc_request_new(server,"wp.getCategories",typeof(int),1,typeof(string),this.username,typeof(string),this.password);
        var session = new SessionAsync();
        var return_code = session.send_message(message);
        if (return_code == 2){
            password_error("Please check your network");
            return {};
        }
        string data = message.response_body.flatten().data;
        
        unowned ValueArray v3;
        Value v = Value(typeof(ValueArray));
        try {
            xmlrpc_parse_method_response(data, -1,v);
        }catch (Error e){ 
            password_error(e.message);
            return {};
        }
        v3 = (ValueArray)v;
        string[] result = {};
        for(int i = 0; i < v3.n_values; i++) {
            var hash = (HashTable<string,Value?>)v3.get_nth(i);

            var x = hash.lookup("description");
            result += x.get_string();
        }
        return result;
        
    }
   
        
    

}



//public class Mxml: Object {

    
//    public static int main(string[] args){
        //var message = xmlrpc_request_new("http://kushaldas.in/xmlrpc.php","wp.getCategories",typeof(int),1,typeof(string),"kd",typeof(string),"babma");
        //var session = new SessionSync();
        //session.send_message(message);
        
        //string data = message.response_body.flatten().data;
        
        //Value v = Value(typeof(string[]));
        //xmlrpc_parse_method_response(data,-1,v);
        //stdout.printf(data);
//        var wp = new Wordpress();
        
        //wp.get_categories();
        //wp.get_last_post();
//        
        //HashTable<string,Value?> hash = new HashTable<string, Value?>.full (str_hash, str_equal, g_free, g_free);
        //Value title = "A title";
        //Value desc = "A big test of description";
        //hash.insert("title",title);
        //hash.insert("description",desc);
        //ValueArray mtags = new ValueArray(1);
        //mtags.append("India");
        //mtags.append("Vala");
        //hash.insert("mt_keywords",mtags);
        //Value v = true;
        //hash.insert("mt_allow_comments",v);
        //debug(wp.post(hash, true));
//        wp.add_category("Vala");
    
//        return 0;
//    }

//}
