#r "Newtonsoft.Json"

using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json;

using System.Text;
using System.Net.Http;

public static async Task<IActionResult> Run(HttpRequest req, ILogger log)
{
    log.LogInformation("FXURL function processed a request.");

    try
    {
        string cid = req.Headers["cid"];
        string secret = req.Headers["secret"];
        string subsid = req.Headers["subsid"];
        string tenantid = req.Headers["tenantid"];
        string rgname = req.Headers["rgname"];
        string sitename = req.Headers["sitename"];
        string fxname = req.Headers["fxname"];

        log.LogInformation($"Headers: {cid}, {subsid}, {tenantid}, {rgname}, {sitename}, {fxname}");

        string token = await GetAccessToken(cid, secret, tenantid, log);
        string url = await GetFxSecret(token, subsid, rgname, sitename, fxname, log);

        return (ActionResult)new OkObjectResult($"{url}");
    }
    catch (Exception ex)
    {
        return new BadRequestObjectResult($"Internal error: {ex.Message}");
    }

}

static async Task<string> GetAccessToken(string cid, string secret, string tenantid, ILogger log)
{
    // http://ronaldrosiernet.azurewebsites.net/Blog/2013/12/07/posting_urlencoded_key_values_with_httpclient

    using (var client = new HttpClient())
    {
        client.BaseAddress = new Uri("https://login.microsoftonline.com");
        var request = new HttpRequestMessage(HttpMethod.Post, $"{tenantid}/oauth2/token");

        var requestContent = $"grant_type=client_credentials&resource=https%3A%2F%2Fmanagement.core.windows.net%2F&client_id={cid}&client_secret={secret}";
        request.Content = new StringContent(requestContent, Encoding.UTF8, "application/x-www-form-urlencoded");

        var response = await client.SendAsync(request);

        var res = await response.Content.ReadAsStringAsync();
        //Console.WriteLine($"{res}");
        var token = JsonConvert.DeserializeObject<Token>(res);

        log.LogInformation(token.access_token);

        return token.access_token;

    }
}

static async Task<string> GetFxSecret(string token, string subsid, string rgname, string appname, string fxname, ILogger log)
{
    using (var client = new HttpClient())
    {
        client.BaseAddress = new Uri("https://management.azure.com");
        var request = new HttpRequestMessage(HttpMethod.Post, $"subscriptions/{subsid}/resourceGroups/{rgname}/providers/Microsoft.Web/sites/{appname}/functions/{fxname}/listsecrets?api-version=2015-08-01");

        var requestContent = string.Format("");
        client.DefaultRequestHeaders.Add("Authorization", "Bearer " + token);
        //request.Content = new StringContent(requestContent, Encoding.UTF8, "application/x-www-form-urlencoded");

        var response = await client.SendAsync(request);

        var res = await response.Content.ReadAsStringAsync();

        var secret = JsonConvert.DeserializeObject<Listsecrets>(res);

        log.LogInformation(secret.trigger_url);

        return secret.trigger_url;

    }
}

class Token
{
    public string token_type { get; set; }
    public int expires_in { get; set; }
    public int ext_expires_in { get; set; }
    public int expires_on { get; set; }
    public int not_before { get; set; }

    public string resource { get; set; }
    public string access_token { get; set; }
}

class Listsecrets
{
    public string key { get; set; }
    public string trigger_url { get; set; }
}