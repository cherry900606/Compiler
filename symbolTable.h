#include <map>
#include <vector>
#include <iostream>
using namespace std;


class symbolTable
{
public:
	symbolTable() { this->count = 0; };
	void create() {}
	int lookup(string s);
	int insert(string s);
	int dump();

private:
	map<string, int> entry; // id_name, index
	int count; // the size of symbol table
	vector<string> record; // record all entries of the sybol table
};

int symbolTable::lookup(string s)
{
	if (entry.count(s))
		return entry[s];
	return -1; // not found
}

int symbolTable::insert(string s)
{
	if(this->lookup(s)!=-1) return this->lookup(s);
	entry[s] = count;
	count++;
	record.push_back(s);
	return entry[s];
}

int symbolTable::dump()
{
	for (int i = 0; i < count; i++)
		cout << record[i] << endl;
	return 0;
}
