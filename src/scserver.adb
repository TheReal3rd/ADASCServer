--Ada general.
with Ada.Text_IO; use Ada.Text_IO;

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

--Project plan: Create a simple relay chat.
-- Keep chat history for x number of messages.
-- Relay all messages.

-- General TODO
-- ADD logging.
-- 

procedure scserver is
    closing : Boolean := False;
    WebServer : AWS.Server.HTTP;

    function responseCallback (Request : in AWS.Status.Data) return AWS.Response.Data is
        URI : constant String := AWS.Status.URI (Request);
        Para : constant AWS.Parameters.List := AWS.Status.Parameters (Request);
    begin
        Put ("->request for: ");
        Put_Line (URI);

        if URI = "/post" then -- Message Filter and post.
            return AWS.Response.Moved (Location => "/", Message => "Posting new message.", Cache_Control => AWS.Messages.Prevent_Cache);
        elsif URI = "/stop" then -- Stop the server (TODO add some sort of verify system.)
            closing := True;
            return AWS.Response.Moved (Location => "/", Message => "Shutting down the server.", Cache_Control => AWS.Messages.Prevent_Cache);
        elsif URI = "/favicon.ico" then -- Return the Sites icon. (TODO create a dedicated icon.)
            return AWS.Response.File(Content_Type => AWS.MIME.Content_Type ("Data/favicon.ico"), FileName => "Data/favicon.ico");
        else -- Return main page
            return AWS.Response.File(Content_Type => AWS.MIME.Content_Type ("Data/index.html"), FileName => "Data/index.html");
        end if;
    end responseCallback;

--TODO Add multi threading if possible.
begin
    Put_Line ("Server Starting...");
    AWS.Server.Start (WebServer, "SCServer", Callback => responseCallback'Unrestricted_Access, Port => 5000);
    loop
        exit when closing = True;
    end loop;
    AWS.Server.Shutdown (WebServer);
    Put_Line ("Server Stopped.");
end scserver;
