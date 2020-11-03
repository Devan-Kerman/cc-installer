package net.devtech.lua.installer.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.util.stream.Collectors;

public class IOUtil {
	public static String readAll(File file) throws IOException {
		return String.join("\n", Files.readAllLines(file.toPath()));
	}

	public static String readAll(InputStream stream) {
		BufferedReader reader = new BufferedReader(new InputStreamReader(stream));
		return reader.lines().collect(Collectors.joining("\n"));
	}
}
