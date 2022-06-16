#include <map>
#include <vector>
#include <iostream>
using namespace std;

enum dtype { Int_type, Float_type, String_type, Bool_type, Non_type,};
enum etype { Val_type, Var_type, Arr_type, Func_type,};

struct Val {
	int ival = 0;
	float fval = 0;
	char* sval = NULL;
	bool bval = false;

	bool isInit = false;
};
string dtypeInt_to_string(int t)
{
	if(t==0) return "int";
	else if(t==1) return "float";
	else if(t==2) return "string";
	else if(t==3) return "bool";
	else if(t==4) return "void";
	else return "error!";
}
string ValInt_to_string(int t)
{
	if(t==0) return "Val_type";
	else if(t==1) return "Var_type";
	else if(t==2) return "Arr_type";
	else if(t==3) return "Func_type";
	else return "error!";
}
struct Entry {
	string ID;
	int dataType; // same as dtype above
	int entryType; // 0:val, 1:var, 2:arr, 3:func, ....etc
	Val val; // value & initialze state
	int arrSize = 0; // ex: arr[10]
	int index;
	
	bool isGlobal = false;
};

class symbolTable
{
public:
	string scopeName;
	vector<Entry> entries;

	symbolTable() { this->scopeName = "unknown"; }
	symbolTable(string name) { this->scopeName = name; }
};

class symbolTables
{
public:
	vector<symbolTable> tables;
	void push_table(string name) { tables.push_back(symbolTable(name)); }
	void push_table() { tables.push_back(symbolTable()); }
	void pop_table() { tables.pop_back(); }

	int insert_entry(Entry e);
	int lookup_entry(Entry e); // find the closest scope
	int lookup_entry_global(string s); // find in all tables
	void dump_table();
	void setFuncTpye(int type);
	int totalIndex = 0;
	
	Entry* getEntry(string s);
	int getIndex(string s);
	bool nowIsFunc = false;
	int nowFuncType = Non_type;
	string nowFuncName = "";
	bool nowIsFor = false;
	string forID = "";
	
	int allFuncCount = 0;
	int nowFuncArgCount = 0;
	
	string getTypeString();

};
string symbolTables::getTypeString()
{
	string s = "";
	int idx = this->tables.size() - 1;
	for (int i = 0; i < this->tables[idx].entries.size(); i++)
	{	
		if(i != 0) s += ", ";
		s += dtypeInt_to_string(this->tables[idx].entries[i].dataType);
	}
	return s;
}
void symbolTables::setFuncTpye(int type)
{
	int idx = this->tables.size() - 1;
	int eidx = this->tables[idx - 1].entries.size() - 1;
	this->tables[idx - 1].entries[eidx].dataType = type;
}
int symbolTables::insert_entry(Entry e)
{
	int idx = this->tables.size() - 1;
	e.index = this->totalIndex++;
	this->tables[idx].entries.push_back(e);
	return this->tables[idx].entries.size() - 1;
}

int symbolTables::lookup_entry(Entry e)
{
	int idx = this->tables.size() - 1;
	for (int i = 0; i < this->tables[idx].entries.size(); i++)
	{
		if (this->tables[idx].entries[i].ID == e.ID)
			return i;
	}
	return -1;
}

int symbolTables::lookup_entry_global(string s)
{
	int idx = this->tables.size() - 1;
	for(int index = idx; index >= 0; index--)
	{
		for (int i = 0; i < this->tables[index].entries.size(); i++)
		{
			if (this->tables[index].entries[i].ID == s)
				return i;
		}
	}
	return -1;
}

void symbolTables::dump_table()
{
	int idx = this->tables.size() - 1;
	cout << "=====symbolTable "<< this->tables[idx].scopeName << "=====" << endl;
	for (int i = 0; i < this->tables[idx].entries.size(); i++)
	{
		cout << this->tables[idx].entries[i].ID << "\t" <<
		dtypeInt_to_string(this->tables[idx].entries[i].dataType) << "\t" <<
		ValInt_to_string(this->tables[idx].entries[i].entryType)  << "\t" << 
		(this->tables[idx].entries[i].val.isInit == true ? "isInit" : "Not init")  << "\t";
		if(this->tables[idx].entries[i].dataType == Int_type)
			cout << this->tables[idx].entries[i].val.ival;
		cout << "\t" << this->tables[idx].entries[i].index;
		cout << endl;
	}
	cout << "=====symbolTable " << this->tables[idx].scopeName << "=====" << endl;
}

Entry* symbolTables::getEntry(string s)
{
	int idx = this->tables.size() - 1;
	for (int index = idx; index >= 0; index--)
	{
		for (int i = 0; i < this->tables[index].entries.size(); i++)
		{
			if (this->tables[index].entries[i].ID == s)
			{
				return &this->tables[index].entries[i];
			}
		}
	}
	Entry *e = new Entry();
	e->ID = "404NotFound";
	return e;
}

int symbolTables::getIndex(string s)
{
	int idx = this->tables.size() - 1;
	for (int index = idx; index >= 0; index--)
	{
		for (int i = 0; i < this->tables[index].entries.size(); i++)
		{
			if (this->tables[index].entries[i].ID == s)
			{
				return this->tables[index].entries[i].index;
			}
		}
	}
	return -1;
}

Entry createEntry(string s, int dtype, int etype, Val v, int arrSize = 0)
{
	Entry e;
	e.ID = s;
	e.dataType = dtype;
	e.entryType = etype;
	e.val = v;
	e.arrSize = arrSize;
	return e;
}


class labelManager
{
	int count;
	string nowL1, nowL2;
	string nowL3, nowL4;
public:
	labelManager() { count = 0;}
	string getLabel() {
		string label = "L" + to_string(this->count);
		count += 1;
		return label;
	}
	void setNowL1(string s) {nowL1 = s;}
	void setNowL2(string s) {nowL2 = s;}
	string getNowL1() {return nowL1;}
	string getNowL2() {return nowL2;}
	
	void setnowL3(string s) {nowL3 = s;}
	void setnowL4(string s) {nowL4 = s;}
	string getnowL3() {return nowL3;}
	string getnowL4() {return nowL4;}
};