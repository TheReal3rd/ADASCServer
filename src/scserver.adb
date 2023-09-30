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
with AWS.Server;
with AWS.Services.Web_Block.Registry;

--Internal
with callbacks;

-- Sources: 
-- https://docs.adacore.com/aws-docs/aws/using_aws.html#building-an-aws-server
-- https://docs.adacore.com/aws-docs/aws/using_aws.html
-- https://en.wikibooks.org/wiki/Ada_Programming/Libraries/Web/AWS

--Project plan: Create a simple chat (Technically complete. Just need to improve it and clean it up.)

-- General TODO
-- ADD logging.
-- Save and Load messages system.
-- Add Server information to the bottom of the HTML page.
-- Complete the HTML page.

procedure scserver is
    --Vars
    webServer : AWS.Server.HTTP;

--TODO Add multi threading if possible. (Research suggests its possible.)
begin
    Put_Line ("Server Starting...");
    --Tip look into the demos section. To learn how to use this. (Web_Block)
    AWS.Services.Web_Block.Registry.Register ("/", "Data/index.thtml", null);
    AWS.Services.Web_Block.Registry.Register ("MESSAGESFORMAT", "Data/messages.thtml", callbacks.messagesFormat'Access, Context_Required => True);

    AWS.Server.Start (webServer, "SCServer", Callback => callbacks.main'Unrestricted_Access, Port => 5000);
    loop
        exit when callbacks.isClosing = True;
    end loop;
    AWS.Server.Shutdown (webServer);
    Put_Line ("Server Stopped.");
end scserver;
