package template;

import java.util.concurrent.atomic.AtomicLong;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
public class App {

  public static void main(String[] args) {
    SpringApplication.run(App.class, args);
  }


	@RestController
	public class MessageController {

		private final AtomicLong counter = new AtomicLong();

		@GetMapping("/message")
		public Message getMessage() {
			return new Message("javaapp", String.format("Hello %s", counter.incrementAndGet()));
		}
	}

  static class Message {
  	private final String from;
  	private final String message;

  	public Message(String from, String message) {
  		this.from = from;
  		this.message = message;
  	}

  	public String getFrom() {
  		return from;
  	}
  	public String getMessage() {
  		return message;
  	}
  }
}
