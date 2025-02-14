import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.batch.item.ItemReader;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class PmcApiItemReader implements ItemReader<PmcDto> {
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    private String nextPageUrl;
    private Iterator<PmcDto> iterator;
    private final List<PmcDto> allResults = new ArrayList<>(); // Collects all results

    public PmcApiItemReader(String apiUrl, RestTemplate restTemplate, ObjectMapper objectMapper) throws Exception {
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
        this.nextPageUrl = apiUrl;
        fetchNextPage(); // 🔥 Make the first API call immediately
    }

    @Override
    public PmcDto read() throws Exception {
        if (iterator == null || !iterator.hasNext()) {
            if (nextPageUrl == null) {
                return null; // No more pages to fetch
            }
            fetchNextPage(); // Fetch next page
        }

        return (iterator != null && iterator.hasNext()) ? iterator.next() : null;
    }

    private void fetchNextPage() throws Exception {
        System.out.println("Fetching data from: " + nextPageUrl);
        String response = restTemplate.getForObject(nextPageUrl, String.class);
        JsonNode jsonNode = objectMapper.readTree(response);

        // Extract `results` and merge them into `allResults`
        JsonNode resultsNode = jsonNode.get("results");
        if (resultsNode != null && resultsNode.isArray()) {
            List<PmcDto> newResults = objectMapper.readerForListOf(PmcDto.class).readValue(resultsNode);
            allResults.addAll(newResults); // Merge new data into list
        }

        // Convert list to iterator for processing
        iterator = allResults.iterator();

        // Extract `pageNext` for the next call
        JsonNode pageNextNode = jsonNode.get("paging").get("pageNext");
        nextPageUrl = (pageNextNode != null && !pageNextNode.isNull()) ? pageNextNode.asText() : null;

        if (nextPageUrl == null) {
            System.out.println("✅ All pages retrieved. Stopping pagination.");
        }
    }
}
