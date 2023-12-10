/**
 * @author Maxpicca
 * @Date 2022-01-01 17:35
 * @Description Talker类实现
 */
public class Talker {
    private String myName;
    private String yourName;
    private Sender sender;
    private Receiver receiver;

    public Talker(String myName, String yourName, int receivePort, int sendPort, int toPort, String toIp) {
        this.myName = myName;
        this.yourName = yourName;
        System.out.print("我是"+this.myName+"，正在连线"+this.yourName+"...\n");
        this.sender = new Sender(sendPort,toIp,toPort, myName);
        this.receiver = new Receiver(receivePort, yourName);
        new Thread(this.sender).start();
        new Thread(this.receiver).start();
    }
}
