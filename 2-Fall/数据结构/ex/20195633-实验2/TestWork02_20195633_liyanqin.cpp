// #include<bits/stdc++.h>
#include<iostream>
#include<sstream>
#include<string>
#include<cmath>
using namespace std;

/*————————————Dictionary————————————*/
template<typename Key, typename E>
class Dictionary{
private:
    void operator=(const Dictionary&){}
    Dictionary(const Dictionary&){}
public:
    Dictionary(){}
    virtual ~Dictionary(){}

    virtual void clear() = 0;
    virtual void insert(const Key &k, const E &e) = 0;
    virtual E remove(const Key &k) = 0;
    virtual E removeAny() = 0;
    virtual E* find(const Key &k) const = 0;
    virtual int size() = 0;
};


/*————————————BinNode————————————*/
template <typename E> 
class BinNode{
public:
    virtual ~BinNode(){}

    virtual E &element() = 0;
    virtual BinNode* left() const = 0;
    virtual BinNode* right() const = 0;

    virtual void setElement(const E &) = 0;
    virtual void setLeft(BinNode *) = 0;
    virtual void setRight(BinNode *) = 0;
    virtual bool isLeaf() = 0;
};

/*-----------BSTNode------------*/
template<typename Key, typename E>
class BSTNode: public BinNode<E>{
private:
    Key k;
    E it;
    BSTNode *lc;
    BSTNode *rc;
public:
    BSTNode() { lc = rc = NULL; }
    BSTNode(Key K, E e, BSTNode* l=NULL, BSTNode* r=NULL){
        k = K; it = e; lc = l; rc = r;
    }
    ~BSTNode(){}

    Key& key() { return k; }
    E& element() { return it; }
    inline BSTNode* left() const { return lc; }
    inline BSTNode* right() const { return rc; }

    void setKey(const Key &K) { k = K; }
    void setElement(const E &e) { it = e; }
    void setLeft(BinNode<E> *b) { lc = (BSTNode *)b; }
    void setRight(BinNode<E> *b) { rc = (BSTNode *)b; }
    bool isLeaf() { return (lc == NULL) && (rc == NULL); }
};

/*-----------BST------------*/
template<typename Key, typename E>
class BST:public Dictionary<Key, E>{
private:
    BSTNode<Key, E> *root;
    int nodecount;

    void clearhelp(BSTNode<Key,E>* root){
        if(root == NULL) return ;
        clearhelp(root->left());
        clearhelp(root->right());
        delete root;
    }
    BSTNode<Key,E>* inserthelp(BSTNode<Key,E>* root,const Key& k, const E& it){
        if(root==NULL)
            return new BSTNode<Key, E>(k, it, NULL, NULL);
        if(k < root->key())
            root->setLeft(inserthelp(root->left(), k, it));
        else
            root->setRight(inserthelp(root->right(), k, it));
        return root;
    }
    BSTNode<Key, E> *deletemin(BSTNode<Key, E> *rt){
        if(rt->left() == NULL)
            return rt->right();
        else{
            rt->setLeft(deletemin(rt->left()));
            return rt;
        }
    }
    BSTNode<Key, E> *getmin(BSTNode<Key, E> *rt){
        if(rt->left() == NULL) return rt;
        else return getmin(rt->left());
    }
    BSTNode<Key, E> *removehelp(BSTNode<Key, E> *rt,const Key& k){
        if(rt == NULL) return NULL;
        else if(k < rt->key())
            rt->setLeft(removehelp(rt->left(), k));
        else if(k > rt->key())
            rt->setRight(removehelp(rt->right(), k));
        else{ // find the target
            BSTNode<Key, E> *temp = rt; 
            if(rt->left()==NULL){
                rt = rt->right();
                delete temp;
            }
            else if(rt->right() == NULL){
                rt = rt->left();
                delete temp;
            }
            else{
                BSTNode<Key, E> *temp = getmin(rt->right());
                rt->setElement(temp->element());
                rt->setKey(temp->key());
                rt->setRight(deletemin(rt->right()));
                delete temp;
            }
        }
        return rt;
    }
    // 为了方便判断数据是否存在，修改了原始数据，原来返回E，现在返回E*
    E* findhelp(BSTNode<Key,E>* root,const Key& k) const{
        if(root == NULL) return NULL;
        if(k < root->key())
            return findhelp(root->left(), k);
        else if(k > root->key())
            return findhelp(root->right(), k);
        else
            return &(root->element());
    }
    void printhelp(BSTNode<Key,E>* root) const{
        if(root == NULL) return ;
        printhelp(root->left());
        cout << root->key() << root->element() <<"\n";
        printhelp(root->right());
    }
    // 自定义函数（封装性不是很好）
    int printFindAhelp(BSTNode<Key,E>* root, char letter){
        if(root==NULL) return 0;
        static int flag = 0;
        printFindAhelp(root->left(),letter);
        if(root->key()[0] == letter){
            cout << root->key() << root->element() << endl;
            flag = 1;
        }
        printFindAhelp(root->right(),letter);
        return flag;
    }
    int printFindDhelp(BSTNode<Key,E>* root, int a,int b, int r){
        if(root==NULL) return 0;
        static int flag = 0;
        printFindDhelp(root->left(),a,b,r);
        int x = root->element().X();
        int y = root->element().Y();
        if(sqrt((x-a)*(x-a)+(y-b)*(y-b)) < r){
            cout << root->key() << root->element() << endl;
            flag = 1;
        }
        printFindDhelp(root->right(),a,b,r);
        return flag;
    }

public:
    BST() { root = NULL; nodecount = 0; }
    ~BST() { clearhelp(root); }

    void clear() { clearhelp(root); root=NULL; nodecount=0;}
    void insert(const Key &k, const E &e) { 
        root = inserthelp(root, k, e);
        nodecount++;
    }
    E remove(const Key& k){
        E* temp = findhelp(root, k);
        if(temp != NULL){
            root = removehelp(root, k);
            nodecount--;
        }
        return *temp;
    }
    E removeAny(){
        if(root!=NULL){
            E temp = root->element();
            root = removehelp(root, root->key());
            nodecount--;
            return temp;
        }
        else return NULL;
    }
    E* find(const Key &k) const { return findhelp(root, k); }
    int size() { return nodecount; }
    void print() const{
        if(root==NULL) cout<<"The BST is empty.\n";
        // else printhelp(root,0);
        else printhelp(root);
    }
    void printFindA(char letter){
        if(printFindAhelp(root,letter)==0) {
            cout << "无满足条件的城市" << endl;
        }
    }
    void printFindD(int a,int b, int r){
        if(printFindDhelp(root, a, b, r)==0) {
            cout << "无满足条件的城市" << endl;
        }
    }
};

/*------------Location------------*/
class Location{
    friend ostream& operator<<(ostream &out, Location A){
        out << "(" << A.X() << "," << A.Y() << ")" ;
        return out;
    }
    friend istream& operator>>(istream &input, Location A){
        int x, y;
        input >> x >> y;
        A.setX(x);
        A.setY(y);
        return input;
    }
private:
    int x;
    int y;
public:
    Location(int a=-1, int b=-1) { x = a; y = b;}
    ~Location(){}

    int X() { return x; }
    int Y() { return y; }
    void setX(int a) { x = a; }
    void setY(int b) { y = b; }
    bool operator==(Location &A){
        return (x == A.X() && y == A.Y());
    }
    bool operator!=(Location &A){
        return (x != A.X() || y != A.Y());
    }
    // void operator=(Location &A){
    //     x = A.X(); y=A.Y();
    // }

};

int main(){
    BST<string, Location> CityData;
    int N, x, y;
    string cityname;
    cout << "请输入待测试数据库中城市的数目(N)和数据(cityname x y)：" << endl;
    scanf("%d\n", &N);
    // cout << "请按格式输入城市信息\"cityname x y\"：" << endl;
    for (int i = 0; i < N; i++){
        cin >> cityname >> x >> y;
        Location *cityXY = new Location(x,y);
        CityData.insert(cityname, *cityXY);
        cityname = "";
        delete cityXY;
        cityXY = NULL;
    }
    cout << "查询指令：\n"
         << "1：新增城市数据\n"
         << "2：删除城市数据\n"
         << "3：查询城市数据\n"
         << "4：查询指定字母打头的所有城市\n"
         << "5：查询指定点(a,b)距离d的所有城市\n"
         << "6：列出所有城市数据\n"
         << "0：退出系统\n";
    // getchar();
    while(true){
        int cmd;
        cout << "请输入指令：";
        scanf("%d", &cmd);
        if(cmd == 1){
            getchar();
            cout << "请按格式输入\"cityname x y\"：" << endl;
            cin >> cityname >> x >> y;
            Location *cityXY = new Location(x,y);
            CityData.insert(cityname, *cityXY);
            cityname = "";
            delete cityXY;
            cityXY = NULL;
        }
        else if(cmd == 2 ){
            getchar();
            cout << "请按格式输入\"cityname\"：" << endl;
            cin >> cityname;
            CityData.remove(cityname);
            cityname = "";
        }
        else if(cmd == 3){
            getchar();
            cout << "请按格式输入\"cityname\"：" << endl;
            cin >> cityname;
            Location *temp = CityData.find(cityname);
            if(temp==NULL){
                cout << "无满足条件的城市" << endl;
            }
            else cout << *temp << endl;
            cityname = "";
        }
        else if(cmd == 4){
            char letter;
            getchar();
            cout << "请按格式输入\"letter\"：" << endl;
            cin >> letter;
            CityData.printFindA(letter);
        }
        else if(cmd == 5){
            int a, b, r;
            cout << "请按格式输入\"a b r\"：" << endl;
            cin >> a >> b >> r;
            CityData.printFindD(a, b, r);
        }
        else if(cmd == 6){
            CityData.print();
        }
        else if(cmd == 0){
            cout << "退出系统" << endl;
            break;
        }
        else {
            cout << "输入有误，请重新输入" << endl;
        }
    }
    return 0;
}