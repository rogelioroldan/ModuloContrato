report 50200 "Contr Trans To Planning Lines"
{
    Caption = 'Contrato Transfer To Planning Lines';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(TransferTo; LineType)
                    {
                        ApplicationArea = All;
                        Caption = 'Transfer To';
                        ToolTip = 'Specifies the type of planning lines that should be created.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        ContratoCalcBatches.TransferToPlanningLine(ContratoLedgEntry, LineType.AsInteger() + 1);
    end;

    var
        ContratoLedgEntry: Record "Contrato Ledger Entry";
        ContratoCalcBatches: Codeunit "Contrato Calculate Batches";
        LineType: Enum ContratoPlanningLineLineType;

    procedure GetContratoLedgEntry(var ContratoLedgEntry2: Record "Contrato Ledger Entry")
    begin
        ContratoLedgEntry.Copy(ContratoLedgEntry2);
    end;
}

