package com.citi.kafka_sample;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class KafkaSampleApplication {

	public static void main(String[] args) {
		SpringApplication.run(KafkaSampleApplication.class, args);
	}

	@Override
	public SMCGoldDto read() throws Exception {
		// Initialize and move to the "results" array
		if (!initialized) {
			while (parser.nextToken() != JsonToken.END_OBJECT) {
				if (Objects.equals(parser.getCurrentName(), "results")) {
					parser.nextToken(); // Move to START_ARRAY
					initialized = true;
					break;
				}
			}
		}

		// Read the next object in the array
		if (parser.nextToken() == JsonToken.START_OBJECT) {
			return objectMapper.readValue(parser, SMCGoldDto.class);
		}

		// Close the parser when the array ends
		if (parser.currentToken() == JsonToken.END_ARRAY) {
			parser.close();
		}

		return null; // No more data to read
	}

}
