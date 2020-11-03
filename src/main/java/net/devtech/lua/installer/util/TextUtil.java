package net.devtech.lua.installer.util;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.Writer;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;

public class TextUtil {
	public static void encode(Path path, Path output) throws IOException {
		encode(path, Files.newBufferedWriter(output));
	}

	public static void encode(Path path, Writer stream) {
		try {
			stream.write('{');
			Files.walkFileTree(path, new SimpleFileVisitor<Path>() {
				@Override
				public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
					stream.append("[\"").append(file.toString().replace('\\', '/')).append("\"]=\"");
					// dump in code
					InputStream in = Files.newInputStream(file);
					encode(in, stream);
					in.close();
					// finish
					stream.write("\",");
					return super.visitFile(file, attrs);
				}
			});
			stream.write('}');
			stream.close();
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	private static final ThreadLocal<byte[]> BUFFERS = ThreadLocal.withInitial(() -> new byte[1024]);
	private static void encode(InputStream stream, Writer writer) throws IOException {
		int len;
		byte[] buffer = BUFFERS.get();
		while ((len = stream.read(buffer)) != -1) {
			ExtendedAscii.encode(writer, buffer, len);
		}
	}
}
