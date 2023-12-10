#include<bits/stdc++.h>
using namespace std;
int MAX_N = 1e5 + 10;
class Rational{
    friend bool operator<(const Rational& r1, const Rational& r2) {
        int n1 = r1.N * r2.D, n2 = r2.N * r1.D;
        return n1 < n2;
    }
    friend bool operator<=(const Rational& r1, const Rational& r2) {
        int n1 = r1.N * r2.D, n2 = r2.N * r1.D;
        return n1 <= n2;
    }
    friend bool operator>(const Rational& r1, const Rational& r2) {
        int n1 = r1.N * r2.D, n2 = r2.N * r1.D;
        return n1 > n2;
    }
    friend bool operator>=(const Rational& r1, const Rational& r2) {
        int n1 = r1.N * r2.D, n2 = r2.N * r1.D;
        return n1 >= n2;
    }
    friend bool operator==(const Rational& r1, const Rational& r2) {
        int n1 = r1.N * r2.D, n2 = r2.N * r1.D;
        return n1 == n2;
    }
    friend bool operator!=(const Rational& r1, const Rational& r2) {
        int n1 = r1.N * r2.D, n2 = r2.N * r1.D;
        return n1 != n2;
    }
    friend ostream& operator<<(ostream &output, const Rational& r){
        if(r.D==1 || r.N==0) {
            output << r.N;
            return output;
        }
        if(r.N%r.D==0) {
            output << r.N/r.D;
            return output;
        }
        // 是否有最大公约数 gcd(n,d)=0
        int n = r.N, d = r.D;
        for (int i = 2; i <= sqrt(min(n, d));i++){
            if(n%i==0 && d%i==0) {
                n /= i;
                d /= i;
            }
        }
        output << n<<"/"<< d;
        return output;
    }

public:
    int N; //分子
    int D; //分母， 要求大于0

    Rational() {}  //default constructor
    Rational(int n){ //constructor for integer value
        this->N = n;
        this->D = 1;
    } 
    Rational(int n, int d) {
        this->N = n;
        this->D = d;
    } //normal constructor
    Rational(const Rational& r){
        this->N = r.N;
        this->D = r.D;
    } //copy constructor
    Rational& operator=(const Rational& r) {
        this->N = r.N;
        this->D = r.D;
        return *this;
    } // assignment override
};

class Comp{
public:
    static bool prior(const Rational& r1, const Rational& r2){
        return r1 < r2;
    }
};

template<typename E,typename Comp>
class heap{
    private:
        E *Heap; 
        int maxsize; // 堆的最大规格
        int n; // 元素个数
        void siftdown(int pos){ // 将Pos放入正确的位置中
            while(!isLeaf(pos)){
                int j = leftchild(pos);
                int rc = rightchild(pos);
                if((rc<n) && Comp::prior(Heap[rc],Heap[j]))
                    j = rc; // 把j赋值给大的那个数
                if(Comp::prior(Heap[pos],Heap[j]))
                    return; // 看看pos能否坐稳那个位置，是则返回，否则换位置
                swap(Heap[pos], Heap[j]);
                pos = j; // move down 继续往下查看
            }
        }
        void siftup(int pos){ // 跟他上司比
            while(true){
                if(pos==0) return;
                int p = parent(pos);
                if(Comp::prior(Heap[pos],Heap[p]))
                    return;
                swap(Heap[pos], Heap[p]);
                pos = p; // move down 继续往下查看
            }
        }

    public:
        heap(E*h,int num,int max){
            Heap = h;
            n = num;
            maxsize = max;
            buildHeap();
        }
        int size() const { return n; }
        int isLeaf(int pos) const { return (pos>=n/2) && (pos<n); }
        int leftchild(int pos) const { return 2*pos+1; } // root从0开始
        int rightchild(int pos) const { return 2*pos+2; }
        int parent(int pos) const { return (pos-1)/2; }
        void buildHeap(){ 
            for (int i = n / 2 - 1; i >= 0;i--) // i = n/2之后的都将是叶结点
                siftdown(i); // 从最下面第一个分支结点往上看，找到合适的位置
        }
        void insert(const E&it){
            if(n > maxsize){
                cout << "Heap is full";
                return;
            }
            int curr = n++;
            Heap[curr] = it;
            // 先插入最后一个，不断和父节点比较，若true则代替父节点，反之则退出循环
            while((curr!=0 && Comp::prior(Heap[curr],Heap[parent(curr)]))){
                swap(Heap[curr],Heap[parent(curr)]);
                curr = parent(curr); // 代替父节点
            }
            // 方法二： shilfup(curr);
        }

        E removefirst(){
            // Assert(n > 0, "Heap is empty");
            n--;
            swap(Heap[0],Heap[n]); // 把最后一个点代替first点
            if(n!=0)
                siftdown(0);
            return Heap[n]; // 之前把first元素和最后一个元素交换了
        }

        E remove(int pos){ // 移除某个特定位置的点
            // Assert((pos >= 0) && (pos < n), "Position is not in the heap.");
            if(pos == (n-1))
                n--;
            else{
                n--;
                swap(Heap[pos],Heap[n]);
                while((pos!=0) && (Comp::prior(Heap[pos],Heap[parent(pos)]))){
                    swap(Heap[pos], Heap[parent(pos)]); // 如果pos的父节点坐不稳那个位置
                    pos = parent(pos); // pos换到父节点那个位置
                }
                if(n!=0)
                    siftdown(pos); // 把pos放在合适的位置
            }
            return Heap[n]; // 返回pos那个要删除的数字
        }

};

int main(){
    int N;
    cin >> N;
    Rational num[MAX_N];
    Rational re[MAX_N];
    heap<Rational,Comp> h(num, N, MAX_N);
    for (int i = 0; i < N;i++){
        int n, d;
        cin >> n >> d;
        Rational temp(n,d);
        num[i] = temp;
        re[i] = temp;
    }
    h.buildHeap();
    for (int i = 0; i < N;i++){
        // print(num[i]);
        cout<<num[i]<<"  ";
    }
    cout << endl;
    for (int i = 0; i < N;i++){
        if(i!=0) cout<<"  ";
        cout << h.removefirst();
    }
    return 0;
}