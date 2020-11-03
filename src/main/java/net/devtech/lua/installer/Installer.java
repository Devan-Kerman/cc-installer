package net.devtech.lua.installer;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringWriter;

import net.devtech.lua.installer.pastebin.PastebinUtil;
import net.devtech.lua.installer.util.TextUtil;

public class Installer {
	public static void main(String[] args) throws IOException {
		System.exit(main0(args));
	}

	public static int main0(String[] args) throws IOException {
		String get = get(args, 0, "No module specified!");
		switch (get) {
		case "publish": {
			File source = new File(get(args, 1, "No source directory!"));
			if (!source.isDirectory()) {
				System.out.println(source + " is not a directory!");
				return 0;
			}

			StringWriter writer = new StringWriter();
			TextUtil.encode(source.toPath(), writer);
			PastebinUtil.createPaste(get(args, 2, "No Pastebin API Key!"),
					writer.toString(),
					get(args, 3, "No Pastebin file name!"));
			break;
		}
		case "export": {
			File source = new File(get(args, 1, "No source directory!"));
			if (!source.isDirectory()) {
				System.out.println(source + " is not a directory!");
				return 0;
			}

			File destination = new File(get(args, 2, "No output file!"));
			TextUtil.encode(source.toPath(), destination.toPath());
			break;
		}
		case "help":
			System.out.println("Installer publish <key> <source> <name>");
			System.out.println("\tkey: pastebin dev key https://pastebin.com/doc_api");
			System.out.println("\tsource: source code directory");
			System.out.println("\tname: name of the file of the paste");
			System.out.println("Installer export <source> <output>");
			System.out.println("\tsource: source code directory");
			System.out.println("\toutput: output file directory");
			break;
		}
		return 1;
	}

	public static String get(String[] args, int index, String err) {
		if (args.length > index) {
			return args[index];
		} else {
			System.out.println(err);
			System.exit(0);
			throw new Error();
		}
	}
}
