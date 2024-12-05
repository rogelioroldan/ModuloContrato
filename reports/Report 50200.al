report 50200 "Contr Trans To Planning Lines"
{
    Caption = 'Job Transfer To Planning Lines';
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
                        ApplicationArea = Jobs;
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
        JobCalcBatches.TransferToPlanningLine(JobLedgEntry, LineType.AsInteger() + 1);
    end;

    var
        JobLedgEntry: Record "Contrato Ledger Entry";
        JobCalcBatches: Codeunit "Contrato Calculate Batches";
        LineType: Enum ContratoPlanningLineLineType;

    procedure GetJobLedgEntry(var JobLedgEntry2: Record "Contrato Ledger Entry")
    begin
        JobLedgEntry.Copy(JobLedgEntry2);
    end;
}

