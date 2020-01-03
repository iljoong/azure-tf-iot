using Microsoft.Azure.EventHubs;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Linq;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace SendSampleData
{
    class Program
    {
        const int numthread = 2; // 61
        const string eventHubName = "testeh";
        // Copy the connection string ("Connection string-primary key") from your Event Hub namespace.
        const string connectionString = "Endpoint=...";

        static void Main(string[] args)
        {
            EventHubIngestion();
        }

        static readonly Random getrandom = new Random();
        static int GetRandomNumber(int min, int max)
        {
            lock (getrandom) // synchronize
            {
                return getrandom.Next(min, max);
            }
        }

        static void EventHubIngestion()
        {
            // updated with .net core
            var connectionStringBuilder = new EventHubsConnectionStringBuilder(connectionString)
            {
                EntityPath = eventHubName
            };
            var eventHubClient = EventHubClient.CreateFromConnectionString(connectionStringBuilder.ToString());

            long counter = 0;
            while(true)
            {
                // https://docs.microsoft.com/en-us/dotnet/api/system.threading.tasks.parallel.for?view=netcore-3.1
                Parallel.For(1, numthread, (i, state) =>
                {
                    try
                    {

                        string recordString = $"MODEL_{GetRandomNumber(0, 100)}";

                        EventData eventData = new EventData(Encoding.UTF8.GetBytes(recordString));
                        eventHubClient.SendAsync(eventData);
                    }
                    catch (Exception exception)
                    {
                        Console.ForegroundColor = ConsoleColor.Red;
                        Console.WriteLine("{0} > Exception: {1}", DateTime.Now, exception.Message);
                        Console.ResetColor();
                    }
                    
                    Thread.Sleep(1000);
                });
                counter++;
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine($"Iteration {counter} done");
            }
        }
    }
}
