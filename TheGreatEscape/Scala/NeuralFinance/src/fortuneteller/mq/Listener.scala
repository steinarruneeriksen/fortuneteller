package fortuneteller.mq
import com.rabbitmq.client.{Channel, Connection, ConnectionFactory, QueueingConsumer}
import akka.actor.Actor
import akka.actor.Props
class Listener(channel: Channel, queue: String, f: (String) => Any) extends Actor {
 
  // called on the initial run
  def receive = {
    case _ => startReceving
  }
 
  def startReceving = {
 
    val consumer = new QueueingConsumer(channel);
    channel.basicConsume(queue, true, consumer);
 
    while (true) {
      // wait for the message
      val delivery = consumer.nextDelivery();
      val msg = new String(delivery.getBody());
 
      // send the message to the provided callback function
      // and execute this in a subactor
      context.actorOf(Props(new Actor {
        def receive = {
          case some: String => f(some);
        }
      })) ! msg
    }
  }
}