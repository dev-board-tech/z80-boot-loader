#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QMessageBox>
#include <QFileDialog>
#include <QDir>
#include <QFile>
#include <QKeyEvent>

void MainWindow::comPortListRfsh() {
    QString t = ui->comboBox_Port->currentText();
    ui->comboBox_Port->clear();
    const auto infos = QSerialPortInfo::availablePorts();
    for (const QSerialPortInfo &info: infos ) {
        ui->comboBox_Port->addItem(info.portName());
    }
    ui->comboBox_Port->setCurrentText(t);
}

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow) {
    ui->setupUi(this);

    ui->plainTextEdit->installEventFilter(this);

    comPortListRfsh();

    serialTimeoutTimer = new QTimer;
    serialTimeoutTimer->setInterval(10);
    sendDataTimer = new QTimer;
    sendDataTimer->setInterval(1);
    serial = new QSerialPort();
    sendState_e = SEND_STATE_IDLE;
    connect(serialTimeoutTimer, &QTimer::timeout, this, [this]() {
        serialTimeoutTimer->stop();
        QString tmpRcvTxt(receiveArray);
        tmpRcvTxt = tmpRcvTxt.replace("\n\r", "\r");
        tmpRcvTxt = tmpRcvTxt.replace("\r\n", "\r");
        if(sendState_e == SEND_STATE_IDLE) {
            int a = ui->plainTextEdit->toPlainText().lastIndexOf("|");
            if(a == 0) {
                ui->plainTextEdit->setPlainText(tmpRcvTxt + "|");
            } else {
                ui->plainTextEdit->setPlainText(ui->plainTextEdit->toPlainText().mid(0, a) + tmpRcvTxt + "|");
            }
        } else if(tmpRcvTxt.contains("Waiting for upload") && sendState_e == SEND_STATE_RESET_WAIT) {
            sendState_e = SEND_STATE_SEND_DATA;
        }
        receiveArray.clear();
    });
    connect(sendDataTimer, &QTimer::timeout, this, [this]() {
        sendDataTimer->stop();
        if(sendState_e == SEND_STATE_RESET) {
            serial->write("r");
            sendState_e = SEND_STATE_RESET_WAIT;
        } else if(sendState_e == SEND_STATE_SEND_DATA){
            QByteArray tmp;
            int remLen = 16;
            if(dataToSend.length() - dataToSendPtr < remLen) {
                remLen = dataToSend.length() - dataToSendPtr;
            }
            if(remLen <= 0) {
                serial->write("\r");
                sendState_e = SEND_STATE_IDLE;
                return;
            }
            tmp = dataToSend.mid(dataToSendPtr, remLen);
            QString arr(tmp.toHex());
            arr = arr.remove('\0');
            serial->write(arr.toLocal8Bit());
            dataToSendPtr += remLen;
            ui->progressBar->setValue(dataToSendPtr);
        }
        sendDataTimer->start();
    });
    connect(serial, &QSerialPort::readyRead, this, [this]() {
        receiveArray.append(serial->readAll());
        serialTimeoutTimer->stop();
        serialTimeoutTimer->start();
    });
    connect(ui->pushButton_Connect, &QPushButton::clicked, this, [this]() {
        if(!ui->pushButton_Connect->text().compare("Open")) {
            ui->pushButton_Connect->setText("Close");
            serial->setPortName(ui->comboBox_Port->currentText());
            serial->setBaudRate(QSerialPort::Baud115200);
            serial->setDataBits(QSerialPort::Data8);
            serial->setParity(QSerialPort::NoParity);
            serial->setStopBits(QSerialPort::OneStop);
            serial->setFlowControl(QSerialPort::HardwareControl);
            if(serial->isOpen() || !serial->open(QIODevice::ReadWrite)) {
                ui->pushButton_Connect->setText("Open");
                QMessageBox messageBox;
                messageBox.critical(0,"Error","Can't open " + serial->portName() + ", error code: " + serial->errorString());
                return;
            }
            ui->plainTextEdit->clear();
            ui->plainTextEdit->setPlainText("|");
            ui->comboBox_Port->setEnabled(false);
        } else {
            ui->pushButton_Connect->setText("Open");
            serial->close();
            ui->comboBox_Port->setEnabled(true);
        }
    });

    connect(ui->pushButton_OpenFile, &QPushButton::clicked, this, [this]() {
        QString filePath(QFileDialog::getOpenFileName(this,
                                                      tr("Open Binary file"), "", tr("Binary Files (*.bin)")));
        if(filePath.length() != 0) {
            ui->label_FilePath->setText(filePath);
        }
    });

    connect(ui->pushButton_Upload, &QPushButton::clicked, this, [this]() {
        if(sendState_e != SEND_STATE_IDLE) {
            return;
        }
        QFile f(ui->label_FilePath->text());
        if(!f.open(QIODevice::ReadOnly)) {
            QMessageBox messageBox;
            messageBox.critical(0,"Error","Can't open file:\r" + f.errorString());
            return;
        }
        ui->progressBar->setMaximum(f.size());
        ui->progressBar->setValue(0);
        dataToSend = f.readAll();
        dataToSendPtr = 0;
        sendState_e = SEND_STATE_RESET;
        sendDataTimer->setInterval(1);
        sendDataTimer->start();
        f.close();
    });
    connect(ui->pushButton_Clear, &QPushButton::clicked, this, [this]() {
        ui->plainTextEdit->clear();
    });
}

MainWindow::~MainWindow() {
    if (serial->isOpen())
        serial->close();
    delete ui;
}

bool MainWindow::eventFilter( QObject *o, QEvent *e ) {
    if ( o == ui->plainTextEdit && e->type() == QEvent::KeyPress ) {
        // special processing for key press
        QKeyEvent *k = (QKeyEvent *)e;
        if(serial->isOpen()) {
            serial->write(QString(k->text().toUtf8().at(0)).toUtf8());
        }
        return true;
    } else if (o == ui->comboBox_Port) {
        if(e->type() == QEvent::MouseButtonPress) {
            comPortListRfsh();
        }
    } else {
        // standard event processing
        return false;
    }
    return QMainWindow::eventFilter(o, e);
}
