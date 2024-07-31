#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include "QtSerialPort/QSerialPort"
#include <QSerialPortInfo>
#include <QTimer>

QT_BEGIN_NAMESPACE
namespace Ui {
class MainWindow;
}
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private:
    enum {
        SEND_STATE_IDLE,
        SEND_STATE_RESET,
        SEND_STATE_RESET_WAIT,
        SEND_STATE_SEND_DATA,
    }sendState_e;

    Ui::MainWindow *ui;
    QSerialPort *serial;

    QTimer *serialTimeoutTimer;
    QTimer *sendDataTimer;

    QByteArray receiveArray;
    QByteArray dataToSend;
    int dataToSendPtr;

    void comPortListRfsh();
protected:
    bool eventFilter( QObject *o, QEvent *e );
};
#endif // MAINWINDOW_H
