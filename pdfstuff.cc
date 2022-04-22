#include <limits.h>
#include <iostream>
#include <fstream>
#include <string>
#include <string_view>
#include <vector>
#include <stack>
#include <unordered_map>
#include <functional>
#include <utility>
#include <podofo/podofo.h>
using namespace PoDoFo;
using std::string;
using std::string_view;
using namespace std::string_view_literals;
// This exists to work around a bug
PdfDestination destination_from_page(PdfDocument *doc, int pageIdx, PdfObject &obj) {
	PdfArray arr;
	arr.push_back(doc->GetPage(pageIdx)->GetObject()->Reference());
	arr.push_back(PdfName("XYZ"));
	arr.push_back(PdfVariant());
	arr.push_back(PdfVariant());
	arr.push_back(PdfVariant());
	obj = arr;
	return PdfDestination(&obj, doc);
}
int parse_roman(string_view sv) {
	int m = 0, d = 0, c = 0, l = 0, x = 0, v = 0, i = 0;
	int cd = 0, xl = 0, iv = 0;
	for (char ch : sv) {
		switch (ch) {
			case 'm': m++; cd += c; c = 0; break;
			case 'd': d++; cd += c; c = 0; break;
			case 'c': c++; xl += x; c = 0; break;
			case 'l': l++; xl += x; x = 0; break;
			case 'x': x++; iv += i; i = 0; break;
			case 'v': v++; iv += i; i = 0; break;
			case 'i': i++; break;
			default: return -1;
		}
	}
	return 1000*m + 500*d + 100*(c-cd) + 50*l + 10*(x-xl) + 5*v + 1*(i-iv);
}
int parse_decimal(string_view sv) {
	int x = 0;
	if (sv.empty())
		return -1;
	for (char c : sv) 
		if (c >= '0' && c <= '9')
			x = 10*x + c-'0';
		else
			return -1;
	return x;
}
struct PageLabelRange {
	enum class Type {
		None,
		Decimal,
		RomanLower
	};
	Type type;
	string prefix;
	int start_idx;
	int start_no;
	int len;
	PdfObject make_obj() const {
		PdfDictionary dict;
		if (type != Type::None)
			dict.AddKey("S", PdfName(type == Type::RomanLower ? "r" : "D"));
		if (!prefix.empty())
			dict.AddKey("P", PdfString(prefix));
		if (start_no != 1)
			dict.AddKey("St", PdfObject((pdf_int64)start_no));
		return dict;
	}
	int decode(string_view sv) const {
		if (prefix.size() > sv.size() || sv.compare(0, prefix.size(), prefix))
			return -1;
		sv.remove_prefix(prefix.size());
		int num = -1;
		switch (type) {
			case Type::RomanLower: num = parse_roman(sv); break;
			case Type::Decimal: num = parse_decimal(sv); break;
			case Type::None: num = sv.empty() ? 1 : -1; break;
		}
		if (num < start_no || num >= start_no+len)
			return -1;
		return num-start_no+start_idx;
	}
};
struct PageLabels {
	std::vector<PageLabelRange> v;
	PdfObject make_obj() const {
		PdfArray arr;
		for (const PageLabelRange &r : v) {
			arr.push_back(pdf_int64(r.start_idx));
			arr.push_back(r.make_obj());
		}
		PdfDictionary dict;
		dict.AddKey("Nums", arr);
		return dict;
	}
	int decode(string_view sv) const {
		for (const PageLabelRange &r : v) {
			int idx = r.decode(sv);
			if (idx != -1)
				return idx;
		}
		return -1;
	}
	void parse_line(string_view sv) {
		int pos1 = sv.find('\t');
		if (pos1 == -1)
			return;
		int pos2 = sv.find('\t', pos1+1);
		if (pos2 == -1)
			return;
		string_view svprefix = sv.substr(0, pos1);
		string_view svnumber = sv.substr(pos1+1, pos2-pos1-1);
		string_view svindex = sv.substr(pos2+1);
		PageLabelRange r;
		using Type = PageLabelRange::Type;
		if (svnumber[0] >= '0' && svnumber[0] <= '9') {
			r.type = Type::Decimal;
			r.start_no = parse_decimal(svnumber);
		} else if (!svnumber.empty()) {
			r.type = Type::RomanLower;
			r.start_no = parse_roman(svnumber);
		} else {
			r.type = Type::None;
			r.start_no = 1;
		}
		r.prefix = svprefix;
		r.start_idx = parse_decimal(svindex) - 1;
		r.len = INT_MAX-r.start_no;
		if (!v.empty())
			v.back().len = r.start_idx - v.back().start_idx;
		v.push_back(r);
	}
};
int main(int argc, const char *argv[]) {
	try {
		PdfError::EnableLogging(false);
		PdfError::EnableDebug(false);
		PdfMemDocument *doc = nullptr;
		PageLabels labels;
		labels.parse_line("\t1\t1");
		
		struct command {
			int argn;
			bool needs_doc;
			std::function<void(const char**)> fn;
		};

		std::unordered_map<string_view, command> commands = {
			{"--debug", {0, false, [](const char **args) {
				(void)args;
				PdfError::EnableLogging(true);
				PdfError::EnableDebug(true);
			}}},
			{"--read", {1, false, [&doc](const char **args) {
				if (doc)
					delete doc;
				doc = new PdfMemDocument(*args);
			}}},
			{"--write", {1, true, [&doc](const char **args) {
				doc->Write(*args);
			}}},
			{"--append", {1, false, [&doc](const char **args) {
				if (doc)
					doc->Append(PdfMemDocument(*args));
				else
					doc = new PdfMemDocument(*args);
			}}},
			{"--title", {1, true, [&doc](const char **args) {
				doc->GetInfo()->SetTitle(*args);
			}}},
			{"--num", {1, true, [&doc, &labels](const char **args) {
				labels = PageLabels();
				if (std::ifstream f(*args); f) {
					string line;
					while (std::getline(f, line))
						if (!line.empty())
							labels.parse_line(line);
				} else {
					std::cerr << "Couldn't open " << *args << '\n';
				}
				if (doc->GetPdfVersion() < ePdfVersion_1_3)
					doc->SetPdfVersion(ePdfVersion_1_3);
				doc->GetCatalog()->GetDictionary().AddKey("PageLabels", labels.make_obj());
			}}},
			{"--toc-clear", {0, true, [&doc](const char **args) {
				(void)args;
				doc->GetCatalog()->GetDictionary().RemoveKey("Outlines");
			}}},
			{"--toc", {1, true, [&doc, &labels](const char **args) {
				PdfObject obj;
				std::stack<PdfOutlineItem*> s;
				s.push(doc->GetOutlines());
				int level = -1;
				if (std::ifstream f(*args); f) {
					string line;
					while (std::getline(f, line))
						if (!line.empty()) {
							int newlevel = 0;
							while (line[newlevel] == '\t')
								newlevel++;
							int pos = line.find('\t', newlevel);
							string_view title = string_view(line).substr(newlevel, pos-newlevel);
							string_view svpage = string_view(line).substr(pos+1);
							int page = labels.decode(svpage);
							if (page == -1)
								std::cerr << "Couldn't decode page " << svpage << '\n';
							if (newlevel == level) {
								s.top() = s.top()->CreateNext(string(title),
									destination_from_page(doc, page, obj));
							} else if (newlevel > level) {
								while (newlevel > level+1) {
									s.push(s.top()->CreateChild("", destination_from_page(doc, 0, obj)));
									std::cerr << "Missing toc level: " << title << '\n';
									level++;
								}
								s.push(s.top()->CreateChild(string(title),
									destination_from_page(doc, page, obj)));
								level++;
							} else {
								while (level > newlevel) {
									s.pop();
									level--;
								}
								s.top() = s.top()->CreateNext(string(title),
									destination_from_page(doc, page, obj));
							}
						}
				} else {
					std::cerr << "Couldn't open " << *args << '\n';
				}
				doc->SetPageMode(ePdfPageModeUseBookmarks);
			}}},
			{"--box", {5, true, [&doc](const char **args) {
				std::unordered_map<string_view, string_view> keynames = {
					{"media", "MediaBox"},
					{"crop", "CropBox"},
					{"bleed", "BleedBox"},
					{"trim", "TrimBox"},
					{"art", "ArtBox"},
				};
				auto it = keynames.find(args[0]);
				if (it == keynames.end()) {
					std::cerr << "Unknown box type" << args[0] << '\n';
					return;
				}
				PdfName key = &it->second[0];
				PdfRect r(atol(args[1])/100., atol(args[2])/100., atol(args[3])/100., atol(args[4])/100.);
				PdfObject obj;
				r.ToVariant(obj);
				int pages = doc->GetPageCount();
				for (int i = 0; i < pages; i++)
					doc->GetPage(i)->GetObject()->GetDictionary().AddKey(key, obj);
			}}},
		};
		
		for (int i = 1; i < argc; i++) {
			auto it = commands.find(argv[i]);
			if (it != commands.end()) {
				if (i+1+it->second.argn > argc) {
					std::cerr << "Not enough args " << argv[i] << '\n';
					return 1;
				}
				if (it->second.needs_doc && !doc) {
					std::cerr << "Command need an open document " << argv[i] << '\n';
					return 1;
				}
				it->second.fn(&argv[i+1]);
				i += it->second.argn;
			} else {
				std::cerr << "Unknown command " << argv[i] << '\n';
				return 1;
			}
		}
		if (doc)
			delete doc;
	} catch (PdfError& e) {
		e.PrintErrorMsg();
		return 1;
	}
}
