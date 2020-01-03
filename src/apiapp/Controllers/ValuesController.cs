using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using apiapp;

using System.Text;
using System.Net;
using System.Net.Http;
using System.Diagnostics;

namespace apiapp.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ValuesController : ControllerBase
    {

        public static string fxurl = Environment.GetEnvironmentVariable("FX_URL");

        // GET api/values
        [HttpGet]
        public ActionResult<IEnumerable<string>> Get()
        {
            Val v = new Val();

            return new string[] { $"values{v.New()}", $"values{v.New()}" };
        }

        [HttpGet("/health")]
        public ActionResult<string> Health()
        {
            return "okay";
        }

        // GET api/values/5
        [HttpGet("{id}")]
        public ActionResult<string> Get(int id)
        {
            return "value";
        }

        // POST api/values
        [HttpPost]
        public async Task<ActionResult> Post([FromBody] string value)
        {
            try
            {
                using (var client = new HttpClient())
                {
                    client.BaseAddress = new Uri(fxurl);
                    var request = new HttpRequestMessage(HttpMethod.Post, $"");

                    var requestContent = $"{{ \"name\": \"{value}\" }}";
                    request.Content = new StringContent(requestContent, Encoding.UTF8, "application/json");

                    var response = await client.SendAsync(request);
                    var content = await response.Content.ReadAsStringAsync();

                    Debug.WriteLine($"status code: {response.StatusCode}");

                    return StatusCode(Convert.ToInt32(response.StatusCode), content);
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }

        }

        // PUT api/values/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody] string value)
        {
        }

        // DELETE api/values/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}
