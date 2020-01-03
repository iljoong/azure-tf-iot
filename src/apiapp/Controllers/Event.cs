using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

using Microsoft.EntityFrameworkCore;

namespace apiapp
{
    public class EventsContext : DbContext
    {   public EventsContext (DbContextOptions<EventsContext> options)
            : base(options)
        {
        }

        public DbSet<Event> events { get; set; }
    }

    public class Page
    {
        public Page(int _total, IEnumerable<Event> _events)
        {
            total = _total;
            events = _events;
        }
        public int total  { get; set; }
        public IEnumerable<Event> events  { get; set; }
    }

    public class Event
    {
        public long id { get; set; }

        public string message { get; set; }

        public DateTime timecreated {get; set;} 
    }
}