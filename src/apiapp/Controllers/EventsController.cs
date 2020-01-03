using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using apiapp;

using Microsoft.EntityFrameworkCore;
using System.Diagnostics;

namespace apiapp.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class EventsController : ControllerBase
    {
        private readonly EventsContext _context;

        public EventsController(EventsContext context)
        {
            _context = context;
        }

        // GET api/values
        [HttpGet]
        public async Task<ActionResult<Page>> Get([FromQuery] int p, [FromQuery] int s = 10)
        {
            try
            {
                var result = from t in _context.events
                             orderby t.timecreated ascending
                             select t;

                int total = await result.CountAsync();
                var events = await result.Skip(s * p).Take(s).ToArrayAsync();

                return new Page(total, events);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }


        // GET api/values/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Event>> Get(int id)
        {
            try
            {
                var evt = from t in _context.events where t.id == id select t;
                if (await evt.AnyAsync())
                {
                    return evt.Single();
                }

                return null;
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        // POST api/values
        [HttpPost]
        public async Task<ActionResult> Post([FromBody] Event evt)
        {
            try
            {
                evt.timecreated = DateTime.Now;
                _context.events.Add(evt);
                await _context.SaveChangesAsync();

                return StatusCode(201);
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error: {ex.Message}");

                return StatusCode(500, ex.Message);
            }
        }

        // PUT api/values/5
        [HttpPut("{id}")]
        public async Task<ActionResult> Put(int id, [FromBody] Event newevt)
        {
            try
            {
                var resp = from t in _context.events where t.id == id select t;
                if (await resp.AnyAsync())
                {
                    var evt = resp.Single();
                    evt.message = newevt.message ?? evt.message;

                    await _context.SaveChangesAsync();
                }

                return StatusCode(200);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }
        // DELETE api/values/5
        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            try
            {
                var resp = from t in _context.events where t.id == id select t;
                if (await resp.AnyAsync())
                {
                    _context.events.Remove(resp.Single());

                    await _context.SaveChangesAsync();
                }
                return StatusCode(200);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }
    }
}
