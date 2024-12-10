table 50233 EstatusAnexo
{
    Caption = 'Estatus Anexos';
    DataCaptionFields = "Código", Nombre;
    DrillDownPageID = "Estatus Anexo List";
    LookupPageID = "Estatus Anexo List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Código"; Code[20])
        {
            Caption = 'Código';

        }
        field(2; "Nombre"; Text[100])
        {
            Caption = 'Nombre';
        }


    }
}