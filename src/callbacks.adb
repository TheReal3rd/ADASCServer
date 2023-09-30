--Ada general.
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded;

--ADA Web Server. (Bad name for the library thought it was amazon web services library for ada.)
with AWS.Response;
with AWS.Status;
with AWS.MIME;
with AWS.Messages;
with AWS.Parameters;
with AWS.Services.Web_Block.Registry;

package body callbacks is
    --Renames
    package UnString renames Ada.Strings.Unbounded;--https://en.wikibooks.org/wiki/Ada_Programming/Strings

    --Types
    type messageData is record -- Hopefully i can store copies of these in an array? You can.
        uname : UnString.Unbounded_String;
        message : UnString.Unbounded_String;
    end record;

    --Arrays can't be unlimited length or expandable. Kinda makes sense. Unlike Java where we can create an array and add data endlessly. However we have memory limits
    --Id say this makes it more safer. I probably should get use too this.
    type messageStorage is
        array(1 .. 20) of messageData;

    --Vars
    index : Integer := 1;
    messages : messageStorage;
    closing : Boolean := False;--Not Ideal prefer it to be in scserver.

    procedure messagesFormat(Request : in Status.Data; Context : not null access Web_Block.Context.Object; Translations : in out Templates.Translate_Set) is
        formattedMessages : UnString.Unbounded_String;
    begin
        for I in messages'Range loop
            declare
                username : constant String := UnString.To_String(messages(I).uname);
                message : constant String := UnString.To_String(messages(I).message);
            begin
                if username'Length >= 1 and message'Length >= 1 then
                    UnString.Append (formattedMessages,"<p>By: " & username  & " Message: " & message & "</p><br>");
                end if;
            end;
        end loop;

        Templates.Insert (Translations, Templates.Assoc ("MESSAGESFORMAT", UnString.To_String (formattedMessages)));
    end messagesFormat;

    function main (Request : in AWS.Status.Data) return AWS.Response.Data is
        URI : constant String := AWS.Status.URI (Request);
        Para : constant AWS.Parameters.List := AWS.Status.Parameters (Request);
        Set : Templates.Translate_Set;
    begin
        Put_Line ("->request for: " & URI);
        if URI = "/post" then -- Message Filter and post.
            declare
                username : constant String := Para.Get("uname");
                message : constant String := Para.Get("message");
                objectData : messageData;
            begin
                if username'Length >= 1 and message'Length >= 1 then
                    Put_Line ("--> New Post by: " & Para.Get("uname") & " Message: " & Para.Get("message")); 
                --TODO Sanitize the user inputs. Not sure how searched it up but couldn't find away todo this. ?
                    objectData.uname := UnString.To_Unbounded_String (username);
                    objectData.message := UnString.To_Unbounded_String (message);
                    messages (index) := objectData;
                    index := index + 1;
                    if index >= 20 then--Note to self. Use this ' to get more options. 
                        index := 1;
                    end if;
                end if;
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
            return Web_Block.Registry.Build (Key => "/", Request => Request, Translations => Set);
        end if;
    end main;

    function isClosing return Boolean is
    begin
        return closing;
    end isClosing;

end callbacks;