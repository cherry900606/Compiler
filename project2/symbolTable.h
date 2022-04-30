#include <map>
#include <vector>
#include <iostream>
using namespace std;

enum dtype
{
	// var 
	Int_type,
	Float_type,
	String_type,
	Bool_type,
	// other
	Non_type,
};
enum etype
{
	Val_type,
	Var_type,
	Arr_type,
	Func_type,
};

struct Val {
	int ival;
	float fval;
	char* sval;
	bool bval;

	bool isInit = false;
};
string dtypeInt_to_string(int t)
{
	if(t==0) return "Int_type";
	else if(t==1) return "Float_type";
	else if(t==2) return "String_type";
	else if(t==3) return "Bool_type";
	else if(t==4) return "Non_type";
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
	void dump_table();
	void setFuncTpye(int type);

};
void symbolTables::setFuncTpye(int type)
{
	int idx = this->tables.size() - 1;
	int eidx = this->tables[idx - 1].entries.size() - 1;
	this->tables[idx - 1].entries[eidx].dataType = type;
}
int symbolTables::insert_entry(Entry e)
{
	int idx = this->tables.size() - 1;
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


void symbolTables::dump_table()
{
	int idx = this->tables.size() - 1;
	cout << "=====symbolTable "<< this->tables[idx].scopeName << "=====" << endl;
	for (int i = 0; i < this->tables[idx].entries.size(); i++)
	{
		cout << this->tables[idx].entries[i].ID << "\t" <<
		dtypeInt_to_string(this->tables[idx].entries[i].dataType) << "\t" <<
		ValInt_to_string(this->tables[idx].entries[i].entryType) << endl;
	}
	cout << "=====symbolTable " << this->tables[idx].scopeName << "=====" << endl;
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
