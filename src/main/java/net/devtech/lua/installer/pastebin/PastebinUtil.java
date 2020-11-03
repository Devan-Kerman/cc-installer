package net.devtech.lua.installer.pastebin;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import net.devtech.lua.installer.util.IOUtil;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;

public class PastebinUtil {
	private static final CloseableHttpClient CLIENT = HttpClients.createMinimal();

	public static void createPaste(String key, String paste, String name) throws IOException {
		HttpPost post = new HttpPost("https://pastebin.com/api/api_post.php");
		List<NameValuePair> nvps = new ArrayList<>();
		nvps.add(new BasicNameValuePair("api_dev_key", key));
		nvps.add(new BasicNameValuePair("api_option", "paste"));
		nvps.add(new BasicNameValuePair("api_paste_code", paste));
		nvps.add(new BasicNameValuePair("api_paste_name", name));
		post.setEntity(new UrlEncodedFormEntity(nvps));
		try (CloseableHttpResponse response = CLIENT.execute(post)) {
			String resp = IOUtil.readAll(response.getEntity().getContent());
			if(resp.startsWith("Bad API Request")) {
				System.out.println("There was a problem reaching pastebin: " + resp);
			} else {
				System.out.println("Pastebin link: " + resp);
			}
		}
	}
}
