with AWS.Response;
with AWS.Status;
with AWS.Templates;
with AWS.Services.Web_Block.Context;

package callbacks is

   use AWS;
   use AWS.Services;

   function main (Request : in AWS.Status.Data) return Response.Data;

   function isClosing return Boolean;

   procedure messagesFormat(Request : in Status.Data; Context : not null access Web_Block.Context.Object;Translations : in out Templates.Translate_Set);

end callbacks;
