--Ada general.
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

--ADA Web Server. (Bad name for the library thought it was amazon web services library for ada.)
with AWS.Server;
with AWS.Response;
with AWS.Status;
with AWS.MIME;
with AWS.Messages;
with AWS.Parameters;

-- Sources: 
-- https://docs.adacore.com/aws-docs/aws/using_aws.html#building-an-aws-server
-- https://docs.adacore.com/aws-docs/aws/using_aws.html
-- https://en.wikibooks.org/wiki/Ada_Programming/Libraries/Web/AWS

--Project plan: Create a simple chat 

-- General TODO
-- ADD logging.
-- 

procedure scserver is
    --Renames
    package UnString renames Ada.Strings.Unbounded;--https://en.wikibooks.org/wiki/Ada_Programming/Strings

    --Types
    type messageData is record -- Hopefully i can store copies of these in an array?
        uname : UnString.Unbounded_String;
        message : UnString.Unbounded_String;
    end record;

    --Arrays can't be unlimited length or expandable. Kinda makes sense. Unlike Java where we can create an array and add data endlessly. However we have memory limits
    --Id say this makes it more safer. I probably should get use too this.
    type messageStorage is
        array(1 .. 20) of messageData;

    --Vars
    closing : Boolean := False;
    webServer : AWS.Server.HTTP;
    index : Integer := 1;
    messages : messageStorage;

    function responseCallback (Request : in AWS.Status.Data) return AWS.Response.Data is
        URI : constant String := AWS.Status.URI (Request);
        Para : constant AWS.Parameters.List := AWS.Status.Parameters (Request);
    begin
        Put_Line ("->request for: " & URI);
        if URI = "/post" then -- Message Filter and post.
            declare
                username : constant String  := Para.Get("uname");
                message : constant String := Para.Get("message");
                objectData : messageData;
            begin
                Put_Line ("--> New Post by: " & Para.Get("uname") & " Message: " & Para.Get("message")); 
               --TODO Sanitize the user inputs. Not sure how searched it up but couldn't find away todo this. ?
                objectData.uname :=  UnString.To_Unbounded_String (username);
                objectData.message := UnString.To_Unbounded_String (message);
                messages (index) := objectData;
                index := index + 1;
                if index >= messages'Length then--Note to self. Use this ' to get more options. 
                    index := 0;
                end if;

                for I in messages'Range loop
                    Put_Line("By: " & UnString.To_String(messages(I).uname) & " Message: " & UnString.To_String(messages(I).message));
                end loop;
            end;
            return AWS.Response.Moved (Location => "/", Message => "Posting new message.", Cache_Control => AWS.Messages.Prevent_Cache);
        elsif URI = "/stop" then -- Stop the server (TODO add some sort of verify system.)
            closing := True;
            return AWS.Response.Moved (Location => "/", Message => "Shutting down the server.", Cache_Control => AWS.Messages.Prevent_Cache);
        elsif URI = "/favicon.ico" then -- Return the Sites icon. (TODO create a dedicated icon.)
            return AWS.Response.File(Content_Type => AWS.MIME.Content_Type ("Data/favicon.ico"), FileName => "Data/favicon.ico");
        elsif URI = "/style.css" then --Style
            return AWS.Response.File(Content_Type => AWS.MIME.Content_Type ("Data/style.css"), FileName => "Data/style.css");
        else -- Return main page
            return AWS.Response.File(Content_Type => AWS.MIME.Content_Type ("Data/index.html"), FileName => "Data/index.html");
        end if;
    end responseCallback;

--TODO Add multi threading if possible. (Research suggests its possible.)
begin
    Put_Line ("Server Starting...");
    AWS.Server.Start (webServer, "SCServer", Callback => responseCallback'Unrestricted_Access, Port => 5000);
    loop
        exit when closing = True;
    end loop;
    AWS.Server.Shutdown (webServer);
    Put_Line ("Server Stopped.");
end scserver;
