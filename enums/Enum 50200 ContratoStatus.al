enum 50200 "Contrato Status"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; Planning)
    {
        Caption = 'Planning';
    }
    value(1; Quote)
    {
        Caption = 'Quote';
    }
    value(2; Open)
    {
        Caption = 'Open';
    }
    value(3; Completed)
    {
        Caption = 'Completed';
    }
}