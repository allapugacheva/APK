#include <windows.h>
#include <stdio.h>

int setComPort(HANDLE com)
{
    DCB dcbSerialParams = {0};
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
    if (!GetCommState(com, &dcbSerialParams)) {       // Получение параметров ком-порта.
        printf("Unable to get state of com port.\n");
        return 0;
    }
    dcbSerialParams.BaudRate = CBR_9600;     // Скорость передачи.
    dcbSerialParams.ByteSize = 8;            // Размер байта.
    dcbSerialParams.StopBits = ONESTOPBIT;   // Длина стопового бита.
    dcbSerialParams.Parity = NOPARITY;       // Паритет (для отслеживания ошибок).
    if (!SetCommState(com, &dcbSerialParams)) {       // Сохранение параметров ком-порта.
        printf("Unable to set state of com port.\n");
        return 0;
    }
    return 1;
}

int main()
{
    HANDLE com1 = CreateFile("COM1", GENERIC_READ|GENERIC_WRITE, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    HANDLE com2 = CreateFile("COM2", GENERIC_READ|GENERIC_WRITE, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    char data[255], result[255];
    DWORD bytesWritten, bytesRead;

    if(com1 == INVALID_HANDLE_VALUE || com2 == INVALID_HANDLE_VALUE)
    {
        printf("Error while open com port.\n");
        CloseHandle(com1);
        CloseHandle(com2);
        return 0;
    }

    if(!setComPort(com1) || !setComPort(com2))
    {
        CloseHandle(com1);
        CloseHandle(com2);
        return 0;
    }

    printf("Enter data to send: ");
    fgets(data, 255, stdin);
    
    if(WriteFile(com1, data, strlen(data), &bytesWritten, NULL))
        printf("Data written succesfully.\n");
    else
    {   
         printf("Error while writing data.\n");
         return 0;
    }

    if(ReadFile(com2, result, strlen(data), &bytesRead, NULL))
        printf("Data read successfully.\n");
    else
    {   
         printf("Error while reading data.\n");
         return 0;
    }
    result[bytesRead] = '\0';
    printf("Read data: %s\n", result);

    CloseHandle(com1);
    CloseHandle(com2);
    return 0;
}