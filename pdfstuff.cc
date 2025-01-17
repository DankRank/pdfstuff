#include <limits.h>
#include <iostream>
#include <fstream>
#include <sstream>
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
int parse_roman(string_view sv, bool is_upper) {
	int m = 0, d = 0, c = 0, l = 0, x = 0, v = 0, i = 0;
	int cd = 0, xl = 0, iv = 0;
	for (char ch : sv) {
		if (is_upper)
			ch += 'a'-'A';
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
int parse_alpha(string_view sv, bool is_upper) {
	int x = 0;
	for (char ch : sv) {
		if (is_upper)
			ch += 'a'-'A';
		if (ch < 'a' || ch > 'z')
			return -1;
		x *= 26;
		x += ch-'a'+1;
	}
	return x;
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
// Algorithm by Knuth
void write_roman(std::ostream &os, int n, bool is_upper) {
	const char *j, *k;
	unsigned u, v;
	j = is_upper ? "M2D5C2L5X2V5I" : "m2d5c2l5x2v5i";
	v = 1000;
	for (;;) {
		while ((unsigned)n >= v)
			os << *j, n -= v;
		if (n <= 0)
			return;
		k = j + 2, u = v / (k[-1]-'0');
		if (k[-1] == '2')
			k += 2, u /= k[-1]-'0';
		if (n + u >= v)
			os << *k, n += u;
		else
			j += 2, v /= j[-1]-'0';
	}
}
void write_alpha(std::ostream &os, int n, bool is_upper) {
	if (n <= 0)
		return;
	int base = 1;
	int len = 26;
	while (n >= base + len) {
		base += len;
		len *= 26;
	}
	n -= base;
	while (len > 1) {
		len /= 26;
		os << (char)((n / len) + (is_upper ? 'A' : 'a'));
		n %= len;
	}
}
struct PageLabelRange {
	enum class Type {
		None = '\0',
		Decimal = 'D',
		RomanUpper = 'R',
		RomanLower = 'r',
		AlphaUpper = 'A',
		AlphaLower = 'a',
	};
	Type type = Type::None;
	string prefix = "";
	int start_idx;
	int start_no = 1;
	int len;
	PdfObject make_obj() const {
		PdfDictionary dict;
		if (type != Type::None) {
			char s[2] = {(char)type};
			dict.AddKey("S", PdfName(s));
		}
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
			case Type::None: num = sv.empty() ? 1 : -1; break;
			case Type::Decimal: num = parse_decimal(sv); break;
			case Type::RomanUpper: num = parse_roman(sv, true); break;
			case Type::RomanLower: num = parse_roman(sv, false); break;
			case Type::AlphaUpper: num = parse_alpha(sv, true); break;
			case Type::AlphaLower: num = parse_alpha(sv, false); break;
		}
		if (num < start_no || num >= start_no+len)
			return -1;
		return num-start_no+start_idx;
	}
	int read_obj(int idx, const PdfDictionary& dict) {
		start_idx = idx;
		if (dict.HasKey("S")) {
			PdfName s = dict.GetKey("S")->GetName();
			if (s.GetLength() != 1)
				return -1;
			switch (s.GetName()[0]) {
				case 'D': case 'R': case 'r': case 'A': case 'a':
					type = (Type)s.GetName()[0];
					break;
				default:
					return -1;
			}
		}
		if (dict.HasKey("P"))
			prefix = dict.GetKey("P")->GetString().GetString();
		if (dict.HasKey("St"))
			start_no = dict.GetKey("St")->GetNumber();
		len = INT_MAX-start_idx;
		return 0;
	}
	string encode(int pageno) const {
		std::stringstream ss;
		ss << prefix;
		switch (type) {
			case Type::None: break;
			case Type::Decimal: ss << pageno; break;
			case Type::RomanUpper: write_roman(ss, pageno, true); break;
			case Type::RomanLower: write_roman(ss, pageno, false); break;
			case Type::AlphaUpper: write_alpha(ss, pageno, true); break;
			case Type::AlphaLower: write_alpha(ss, pageno, false); break;
		}
		return ss.str();
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
		} else if (svnumber[0] == '_') {
			svnumber.remove_prefix(1);
			r.type = svnumber[0] > 'A' && svnumber[0] < 'Z' ? Type::AlphaUpper : Type::AlphaLower;
			r.start_no = parse_alpha(svnumber, r.type == Type::AlphaUpper);
		} else if (!svnumber.empty()) {
			r.type = svnumber[0] > 'A' && svnumber[0] < 'Z' ? Type::RomanUpper : Type::RomanLower;
			r.start_no = parse_roman(svnumber, r.type == Type::RomanUpper);
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
	void walk(const PdfDictionary &dict) {
		if (dict.HasKey("Kids")) {
			for (const PdfObject &obj : dict.MustGetKey("Kids").GetArray())
				walk(obj.GetOwner()->MustGetObject(obj.GetReference())->GetDictionary());
		} else {
			const PdfArray &arr = dict.MustGetKey("Nums").GetArray();
			for (auto it = arr.begin(); it != arr.end(); ++it) {
				int idx = it->GetNumber();
				if (++it == arr.end())
					break;
				const PdfDictionary &d = it->GetDictionary();
				PageLabelRange r;
				if (r.read_obj(idx, d) != -1)
					v.push_back(r);
			}
		}
	}
};
void walk_outline(int level, PdfOutlineItem *outline) {
	while (outline) {
		for (int i = 0; i < level; i++)
			std::cout << '\t';
		PdfDocument *doc = outline->GetObject()->GetOwner()->GetParentDocument();
		std::cout << outline->GetTitle().GetString() << '\t'
			<< outline->GetDestination(doc)->GetPage(doc)->GetPageNumber() << '\n';
		walk_outline(level+1, outline->First());
		outline = outline->Next();
	}
}
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
				doc->GetInfo()->SetTitle((const pdf_utf8*)*args);
			}}},
			{"--num-dump", {0, true, [&doc](const char **args) {
				(void)args;
				PageLabels labels;
				labels.walk(doc->GetCatalog()->GetDictionary().MustGetKey("PageLabels").GetDictionary());
				for (const auto &r : labels.v)
					std::cout << r.prefix << '\t' << r.encode(r.start_no) << '\t' << r.start_no << '\n';
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
			{"--toc-dump", {0, true, [&doc](const char **args) {
				(void)args;
				PdfOutlineItem *outline = doc->GetOutlines(ePdfDontCreateObject);
				// TODO: use PageLabels
				if (outline)
					walk_outline(0, outline->First());
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
							string stitle = string(string_view(line).substr(newlevel, pos-newlevel));
							pdf_utf8 *title = (pdf_utf8*)stitle.c_str();
							string_view svpage = string_view(line).substr(pos+1);
							int page = labels.decode(svpage);
							if (page == -1)
								std::cerr << "Couldn't decode page " << svpage << '\n';
							if (newlevel == level) {
								s.top() = s.top()->CreateNext(title,
									destination_from_page(doc, page, obj));
							} else if (newlevel > level) {
								while (newlevel > level+1) {
									s.push(s.top()->CreateChild("", destination_from_page(doc, 0, obj)));
									std::cerr << "Missing toc level: " << title << '\n';
									level++;
								}
								s.push(s.top()->CreateChild(title,
									destination_from_page(doc, page, obj)));
								level++;
							} else {
								while (level > newlevel) {
									s.pop();
									level--;
								}
								s.top() = s.top()->CreateNext(title,
									destination_from_page(doc, page, obj));
							}
						}
				} else {
					std::cerr << "Couldn't open " << *args << '\n';
				}
				doc->SetPageMode(ePdfPageModeUseBookmarks);
			}}},
			{"--pagemode", {1, true, [&doc](const char **args) {
				static const std::unordered_map<string_view, EPdfPageMode> modenames = {
					{"none", ePdfPageModeUseNone},
					{"thumbs", ePdfPageModeUseThumbs},
					{"outlines", ePdfPageModeUseBookmarks},
					{"fullscreen", ePdfPageModeFullScreen},
					{"oc", ePdfPageModeUseOC},
					{"attachments", ePdfPageModeUseAttachments},
				};
				auto it = modenames.find(args[0]);
				if (it == modenames.end()) {
					std::cerr << "Unknown mode type" << args[0] << '\n';
					return;
				}
				doc->SetPageMode(it->second);
			}}},
			{"--box", {5, true, [&doc](const char **args) {
				static const std::unordered_map<string_view, string_view> keynames = {
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
			{"--rotate-page", {2, true, [&doc](const char **args) {
				doc->GetPage(atol(args[0])-1)->SetRotation(atol(args[1]));
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
