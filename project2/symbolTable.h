#include <map>
#include <vector>
#include <iostream>
using namespace std;

enum dtype {
	// var 
	Int_type, Float_type, String_type, Bool_type,
	// other
	Non_type,
};
enum etype {
	Val_type, Var_type, Arr_type, Func_type,
};

struct Val {
	int ival = 0;
	float fval = 0;
	char* sval = NULL;
	bool bval = false;

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
	int lookup_entry_global(string s); // find in all tables
	void dump_table();
	void setFuncTpye(int type);
	
	Entry* getEntry(string s);
	
	bool nowIsFor = false;
	string forID = "";

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
/* todo list 
* 1. check the ID is declared in this scope (or in the previous scope) Y
* 2. check func invoke, which is same as 1. Y
* 3. return type for func invoke ( ex: c = add(a, 10)) (type checking
* 4. expression return val and store in symbol table (necessary?
* 5. for ( id in xx..xx) <- add id into symbol table
* 6. func return type should be dame as declaration
* 7. what is the definition of bool_expr?
* 8. check at least one func
* 9. arr len >= 1 and index must be int
* 10. arr index out of range
*/

